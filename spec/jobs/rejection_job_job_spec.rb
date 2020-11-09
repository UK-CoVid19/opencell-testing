require 'rails_helper'

RSpec.describe RejectionJob, type: :job do
  
  include ActiveJob::TestHelper

  it "should perform a correct request" do
    @user = create(:user)
    @client = create(:client, notify: true)
    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:rejected], client: @client)
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Inconclusive"
    }
    allow_any_instance_of(RejectionJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("200", "OK"))
    RejectionJob.perform_now(@sample, @user)
    assert @sample.commcomplete?
  end

  it "should fail when not 2XX " do
    @user = create(:user)
    @client = create(:client, notify: true)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:rejected], client: @client)
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Inconclusive"
    }
    allow_any_instance_of(RejectionJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("400", "bad request"))
    RejectionJob.perform_now(@sample, @user)
    assert @sample.commfailed?
  end

  it "should throw if not set to rejected when received " do
    @user = create(:user)
    @client = create(:client, notify: true)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:requested], client: @client)
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Inconclusive"
    }
    allow_any_instance_of(RejectionJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("400", "bad request"))

    func = -> {RejectionJob.perform_now(@sample, @user)}
    expect{ func.call }.to raise_error StandardError, "requested Invalid state to send rejection"
  end

  it "should not throw if not set to commfailed if a record has rejected set when received " do
    @user = create(:user)
    @client = create(:client, notify: true)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:rejected], client: @client)
      @sample.commfailed!
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Inconclusive"
    }
    allow_any_instance_of(RejectionJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("400", "bad request"))

    func = -> {RejectionJob.perform_now(@sample, @user)}
    expect{ func.call }.to_not raise_error
  end

  it "should throw if not set to commfailed if a record has not had rejected set when received " do
    @user = create(:user)
    @client = create(:client, notify: true)

    Sample.with_user(@user) do
      @sample = create(:sample, state: Sample.states[:communicated], client: @client)
      @sample.commfailed!
    end
    expected = {
      'sampleid' => @sample.uid,
      'result' => "Inconclusive"
    }
    allow_any_instance_of(RejectionJob).to receive(:make_request).with(expected, @sample.client).and_return(TestDummy.new("400", "bad request"))

    func = -> {RejectionJob.perform_now(@sample, @user)}
    expect{ func.call }.to raise_error StandardError, "commfailed Invalid state to send rejection"
  end
end

class TestDummy
  def initialize(code, body = "something")
    @code = code
    @body = body
  end

  attr_accessor :code
  attr_accessor :body
end
