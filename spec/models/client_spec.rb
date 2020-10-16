require 'rails_helper'

RSpec.describe Client, type: :model do

  describe "validations" do
    it "should not allow a duplicate name" do
      @client_a = create(:client, name: "myname")
      @client_b = build(:client, name: "myname")

      expect(@client_b.save).to eq false
      expect(@client_b.errors).to_not be nil
      expect(@client_b.errors[:name].first).to eq "has already been taken"
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
      @client_a = Client.new(name: 'blah', notify: false)
      expect { @client_a.save }.to raise_error "API key required"
    end

    it "should create a valid record" do
      @client_a = Client.new(name: 'blah', api_key: 'abc', notify: false)
      expect(@client_a.save).to eq true
    end

    it "should create only 1 instance of the control client" do
      control = Client.control_client
      control_2 = Client.control_client
      expect(control).to eq control_2
    end
  end

  describe "stats" do
    before :each do
      @user = create(:user)
      @client = create(:client)
    end

    it "should generate valid stats when samples are created straight at commcomplete stage" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :commcomplete, client: @client)
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 0
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq 1
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
        @sample.analysed!
        @sample.communicated!
        @sample.commcomplete!
        @stats = @client.stats
        expect(@stats.first.communicated).to eq 1
        expect(@stats.first.requested).to eq 1
        expect(@stats.first.retests).to eq 0
        expect(@stats.first.rejects).to eq 0
        expect(@stats.first.internalchecks).to eq 0
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
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
        expect(@stats.size).to eq 1
      end
    end
  end
end
