require 'net/http'

class ResultNotifyJob < ApplicationJob
  queue_as :default

  def perform(sample)
    to_send = {
      'sample_id' => sample.uid,
      'result' => get_result(sample.test_result.state)
    }
    url = URI.parse(ENV['NOTIFY_URL'])
    username_password = "#{ENV['NOTIFY_USERNAME']}:#{ENV['NOTIFY_PASSWORD']}"
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    request['Accept'] = '*/*'
    request['Authorization'] = "Basic #{Base64.encode64(username_password).gsub('\n', '')}"
    request.body = to_send.to_json

    response = http.request(request)
    return unless response.code != '200'

    raise StandardError.new(response), "Request failed with code #{response.code} and body #{response.body}"
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
end
