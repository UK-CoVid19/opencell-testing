require 'rails_helper'

RSpec.describe ResultNotifyJob, type: :job do
  include ActiveJob::TestHelper

  it "should perform a correct request " do
    @user = create(:user)
    @client = create(:client, notify: true)

    @wells = build_list(:well, 96)
    @plate = create(:plate, wells: @wells, lab: @client.labgroup.labs.first)

    @test = create(:test, plate: @plate, user: @user)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:tested], client: @client)

      @plate.wells.third.sample = @sample
      @test_result = create(:test_result, test: @test, well: @plate.wells.third, state: TestResult.states[:positive])

      expected = {
        'sampleid' => @sample.uid,
        'result' => "Positive"
      }
      allow_any_instance_of(ResultNotifyJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("200"))
      @sample.communicated!
    end

    expect { perform_enqueued_jobs }.to_not raise_error

    @sample.reload
    expect(@sample.commfailed?).to eq false
    expect(@sample.commcomplete?).to eq true
    expect(@sample.records.last.user).to eq @user
  end

  it "should fail when not 2XX " do
    @user = create(:user)
    @client = create(:client, notify: true)

    @wells = build_list(:well, 96)
    @plate = create(:plate, wells: @wells, lab: @client.labgroup.labs.first)

    @test = create(:test, plate: @plate, user: @user)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:tested], client: @client)

      @plate.wells.third.sample = @sample
      @test_result = create(:test_result, test: @test, well: @plate.wells.third, state: TestResult.states[:positive])

      expected = {
        'sampleid' => @sample.uid,
        'result' => "Positive"
      }
      allow_any_instance_of(ResultNotifyJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("400", "bad request"))
      @sample.communicated!
    end

    expect { perform_enqueued_jobs }.to raise_error ClientNotifyModule::NotifyException

    @sample.reload
    expect(@sample.commfailed?).to eq true
    expect(@sample.records.last.user).to eq @user
  end
end

class TestDummy
  def initialize(code, body = nil)
    @code = code
    @body = body
  end

  attr_accessor :code
  attr_accessor :body
end
