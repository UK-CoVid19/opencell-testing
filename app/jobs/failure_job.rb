class FailureJob < ApplicationJob
  queue_as :default

  extend ClientNotifyModule

  def perform(sample, user)
    sample.with_user(user) do |s|
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
      'result' => INCONCLUSIVE
    }
    response = make_request(to_send)
    if [200, 202].include? response.code.to_i
      sample.commcomplete!
      return
    end

    sample.commfailed!
    raise NotifyException.new(response), "Request failed with code #{response.code} and body #{response.body}"
  end
end
