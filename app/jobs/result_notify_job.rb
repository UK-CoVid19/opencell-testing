require 'net/http'

class ResultNotifyJob < ApplicationJob
  class NotifyException < StandardError
  end

  ALL_NET_HTTP_ERRORS = [
    Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  ]
  queue_as :default

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
    response = make_request(sample)
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
      'Positive'
    when TestResult.states[:lowpositive]
      'Positive'
    when TestResult.states[:negative]
      'Negative'
    when TestResult.states[:inhibit]
      'Inconclusive'
    end
  end

  def make_request(sample)
    
    puts "making request"
    to_send = {
      'sampleid' => sample.uid,
      'result' => get_result(sample.test_result.state)
    }
    url = URI.parse(ENV['NOTIFY_URL'])
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['NOTIFY_USERNAME'], ENV['NOTIFY_PASSWORD'])
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    request['Accept'] = '*/*'
    request['Authorization'] = authorization
    request['apikey'] = ENV['NOTIFY_API_KEY']
    request.body = to_send.to_json

    response = nil
    begin
      response = http.request(request)
    rescue *ALL_NET_HTTP_ERRORS => e
      sample.commfailed!
      Rails.logger.error("Request failed with exception #{e}")
      raise NotifyException.new(e), "Request failed with exception #{e}"
    end
    response
  end
end
