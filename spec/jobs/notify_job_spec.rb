require 'rails_helper'

RSpec.describe ResultNotifyJob, type: :job do
  include ActiveJob::TestHelper

  it "should perform a correct request " do
    @user = create(:user)
    @client = create(:client, notify: true)

    @wells = build_list(:well, 96)
    @plate = create(:plate, wells: @wells)

    @test = create(:test, plate: @plate)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:tested], client: @client)
    

    @plate.wells.third.sample = @sample
    @test_result = create(:test_result, test: @test, well: @plate.wells.third, state: TestResult.states[:positive])
    @sample.communicated!
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Positive"
    }
    allow_any_instance_of(ResultNotifyJob).to receive(:make_request).with(expected).and_return(TestDummy.new("200"))
    ResultNotifyJob.perform_now(@sample, @user)
    assert @sample.commcomplete?
    
  end

  it "should fail when not 2XX " do
    @user = create(:user)
    @client = create(:client, notify: true)

    @wells = build_list(:well, 96)
    @plate = create(:plate, wells: @wells)

    @test = create(:test, plate: @plate)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:tested], client: @client)

    @plate.wells.third.sample = @sample
    @test_result = create(:test_result, test: @test, well: @plate.wells.third, state: TestResult.states[:positive])
    @sample.communicated!
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Positive"
    }
    allow_any_instance_of(ResultNotifyJob).to receive(:make_request).with(expected).and_return(TestDummy.new("400", "bad request"))
    ResultNotifyJob.perform_now(@sample, @user)
    assert @sample.commfailed?

  end
end

class TestDummy
  def initialize(code, body)
    @code = code
    @body = body
  end

  attr_accessor :code
  attr_accessor :body
end
