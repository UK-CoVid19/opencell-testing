class RejectionJob < ApplicationJob
  queue_as :default

  include ClientNotifyModule

  retry_on NotifyException

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

    unless sample.rejected?
      raise "Invalid state to send rejection"
    end

    to_send = {
      'sampleid' => sample.uid,
      'result' => INCONCLUSIVE
    }
    response = make_request(to_send, sample.client)
    if [200, 202].include? response.code.to_i
      sample.commcomplete!
      return
    end

    sample.commfailed!
    raise NotifyException.new(response), "Request failed with code #{response.code} and body #{response.body}"
  end
end
