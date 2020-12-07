require 'rails_helper'

RSpec.describe Client, type: :model do

  describe "validations" do

    before :each do
      @labgroup = create(:labgroup)
    end

    it "should not allow a duplicate name for the same labgroup" do
      @client_a = create(:client, name: "myname", labgroup: @labgroup)
      @client_b = build(:client, name: "myname", labgroup: @labgroup)

      expect(@client_b.save).to eq false
      expect(@client_b.errors).to_not be nil
      expect(@client_b.errors[:name].first).to eq "has already been taken"
    end

    it "should allow a duplicate name for the same labgroup" do
      @client_a = create(:client, name: "myname", labgroup: @labgroup)
      @client_b = build(:client, name: "myname", labgroup: create(:labgroup))

      expect(@client_b.save).to eq true
      expect(@client_b.errors).to be_empty
    end

    it "should allow a different names" do
      @client_a = create(:client, name: "myname")
      @client_b = build(:client, name: "myname2")

      expect(@client_b.save).to eq true
      expect(@client_b.errors.size).to eq 0
    end

    it "should require a URL when notify is set to true" do
      @client = build(:client, name: "myname2", notify: true, url: nil)
      expect(@client.save).to eq false
      expect(@client.errors.size).to eq 2
      expect(@client.errors[:url].size).to eq 2
    end

    it "should require a URL when notify is set to true" do
      @client = build(:client, name: "myname2", notify: true, url: "https://blah.com")
      expect(@client.save).to eq true
    end

    it "should require a https URL " do
      @client = build(:client, name: "myname2", notify: true, url: "http://blah.com")
      expect(@client.save).to eq false
      expect(@client.errors[:url].size).to eq 1
    end

    it "should not require a URL when notify is set to false" do
      @client = build(:client, name: "myname2", notify: false, url: nil)
      expect(@client.save).to eq true
    end

    it "should require api key" do
      @client_a = Client.new(name: 'blah', notify: false, labgroup: @labgroup)
      expect { @client_a.save }.to raise_error "API key required"
    end

    it "should require a labgroup api key" do
      @client_a = Client.new(name: 'blah', notify: false, api_key: 'blah')
      expect(@client_a.save).to eq false
      expect(@client_a.errors[:labgroup].first).to eq "must exist"
    end

    it "should create a valid record" do
      @client_a = Client.new(name: 'blah', api_key: 'abc', notify: false, labgroup: @labgroup)
      expect(@client_a.save).to eq true
    end

    it "should create only 1 instance of the control client per labgroup" do
      labgroup = create(:labgroup)
      control = Client.control_client(labgroup)
      control_2 = Client.control_client(labgroup)
      expect(control).to eq control_2
      expect(control.api_key.size).to eq 24
    end

    it "should create different control clients for different labgroups" do
      labgroup = create(:labgroup)
      labgroup_2 = create(:labgroup)
      control = Client.control_client(labgroup)
      control_2 = Client.control_client(labgroup_2)
      expect(control).to_not eq control_2
    end
  end

  describe "test webhook" do
    it "should send an inconclusive test message to the endpoint" do
      @client = create(:client, notify: true)
      expected = {
        'sampleid' => "TEST",
        'result' => ClientNotifyModule::INCONCLUSIVE
      }
      allow(@client).to receive(:make_request).with(expected, @client).and_return(TestDummy2.new("200", {}))
      expect(@client.test_webhook).to eq true
    end

    it "should fail an inconclusive test message to the endpoint" do
      @client = create(:client, notify: true)
      expected = {
        'sampleid' => "TEST",
        'result' => ClientNotifyModule::INCONCLUSIVE
      }
      allow(@client).to receive(:make_request).with(expected, @client).and_return(TestDummy2.new("401", {}))
      expect(@client.test_webhook).to eq false
    end

    it "should throw if client cannot notify" do
      @client = create(:client, notify: false)
      expected = {
        'sampleid' => "TEST",
        'result' => ClientNotifyModule::INCONCLUSIVE
      }
      allow(@client).to receive(:make_request).with(expected, @client).and_return(TestDummy2.new("401", {}))
      expect { @client.test_webhook }.to raise_error("Client cannot notify")
    end

    class TestDummy2
      def initialize(code, body)
        @code = code
        @body = body
      end

      attr_accessor :code
      attr_accessor :body
    end
  end

  describe "stats" do
    before :each do
      @user = create(:user)
      @labgroup = create(:labgroup)
      @client = create(:client, labgroup: @labgroup)
    end

    it "should generate valid stats when samples are created straight at commcomplete stage" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :tested, client: @client)
        @plate = create(:plate, wells: build_list(:well, 96), lab: @labgroup.labs.first)
        @plate.wells.last.tap do |w|
          w.sample = @sample
          w.save!
        end
        @test = create(:test, plate: @plate)
        @test_result = create(:test_result, well: @plate.wells.last, test: @test, state: TestResult.states[:positive])
        @sample.communicated!
        @sample.commcomplete!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 0
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.first.positives).to eq 1
        expect(@stats.first.negatives).to eq 0
        expect(@stats.first.inconclusives).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should record the request and communication of a sample" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @sample.prepared!
        @sample.prepared!
        @sample.tested!
        @plate = create(:plate, wells: build_list(:well, 96), lab: @labgroup.labs.first)
        @plate.wells.last.tap do |w|
          w.sample = @sample
          w.save!
        end
        @test = create(:test, plate: @plate)
        @test_result = create(:test_result, well: @plate.wells.last, test: @test, state: TestResult.states[:positive])
        @sample.analysed!
        @sample.communicated!
        @sample.commcomplete!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.first.positives).to eq 1
        expect(@stats.first.negatives).to eq 0
        expect(@stats.first.inconclusives).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should record the request and rejection of a sample" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @sample.rejected!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 0
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 1
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should record the request and rerun of a sample" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @sample.retest!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 0
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 1
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should not record samples that are not created from the API" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Not Created from API'
        r.save!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 0
        expect(@stats.first.requested).to eq 0
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should record the communication of a retest" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @retest = @sample.create_retest(Rerun::POSITIVE)
        @rerun = @retest
        @rerun.preparing!
        @rerun.prepared!
        @rerun.prepared!
        @rerun.tested!
        @rerun.analysed!
        @rerun.communicated!
        @rerun.commcomplete!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 1
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should count a posthoc retest as a communicated sample, however the retest count should differentiate communicating and noncommunicating retests" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @sample.prepared!
        @sample.prepared!
        @sample.tested!
        @sample.analysed!
        @sample.communicated!
        @sample.commcomplete!
        @p_retest = @sample.create_posthoc_retest(Rerun::POSITIVE)
        @p_retest.preparing!
        @p_retest.prepared!
        @p_retest.prepared!
        @p_retest.tested!
        @p_retest.analysed!
        @p_retest.communicated!
        @p_retest.commcomplete!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.internalchecks).to eq 1
        expect(@stats.first.rejects).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end

    it "should count a posthoc retest as a communicated sample, however the retest count should differentiate communicating and noncommunicating retests with an internal retest too" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received, client: @client)
        r = @sample.records.first
        r.note = 'Created from API'
        r.save!
        @sample.preparing!
        @sample.prepared!
        @sample.prepared!
        @sample.tested!
        @sample.analysed!
        @sample.communicated!
        @sample.commcomplete!
        @p_retest = @sample.create_posthoc_retest(Rerun::POSITIVE)

        @sample_2 = create(:sample, state: :received, client: @client)
        r = @sample_2.records.first
        r.note = 'Created from API'
        r.save!
        @sample_2.preparing!
        @sample_2.prepared!
        @sample_2.prepared!
        @sample_2.tested!
        @p_2_retest = @sample_2.create_retest(Rerun::POSITIVE)

        @stats = @client.stats

        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 2
        expect(@stats.first.retests).to eq 1
        expect(@stats.first.internalchecks).to eq 1
        expect(@stats.first.rejects).to eq 0
        expect(@stats.size).to eq (Date.today - Date.parse("2020-09-11")).to_i + 1
      end
    end
  end
end
