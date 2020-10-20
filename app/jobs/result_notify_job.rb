require 'net/http'

class ResultNotifyJob < ApplicationJob
  include ClientNotifyModule

  queue_as :default

  retry_on NotifyException

  def perform(sample)
    sample.with_user(sample.test_result.test.user) do |s|
      send_message(s)
    end
  end

  private
  def send_message(sample)
    unless sample.client.notify
      sample.commcomplete!
      return
    end

    to_send = {
      'sampleid' => sample.uid,
      'result' => get_result(sample.test_result.state)
    }
    response = make_request(to_send, sample.client)
    if [200, 202].include? response.code.to_i
      sample.commcomplete!
      return
    end

    sample.commfailed!
    raise NotifyException.new(response), "Request failed with code #{response.code} and body #{response.body}"
  end

  def get_result(result)
    case TestResult.states.to_hash[result]
    when TestResult.states[:positive]
      POSITIVE
    when TestResult.states[:lowpositive]
      POSITIVE
    when TestResult.states[:negative]
      NEGATIVE
    when TestResult.states[:inhibit]
      INCONCLUSIVE
    end
  end
end
