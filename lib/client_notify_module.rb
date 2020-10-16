module ClientNotifyModule
  class NotifyException < StandardError
  end

  POSITIVE = 'Positive'.freeze
  NEGATIVE = 'Negative'.freeze
  INCONCLUSIVE = 'Inconclusive'.freeze

  ALL_NET_HTTP_ERRORS = [
    Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
    Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
  ].freeze

  def make_request(to_send, client)

    url = URI.parse(client.url ||= ENV['NOTIFY_URL'])
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    request['Accept'] = '*/*'
    client.headers.each do |header|
      request[header.key] = header.value
    end
    # fallback
    if client.headers.empty?
      request['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['NOTIFY_USERNAME'], ENV['NOTIFY_PASSWORD'])
      request['apikey'] = ENV['NOTIFY_API_KEY']
    end
    request.body = to_send.to_json

    response = nil
    begin
      response = http.request(request)
    rescue *ALL_NET_HTTP_ERRORS => e
      puts e.to_json
      Rails.logger.error("Request failed with exception #{e}")
      raise NotifyException.new(e), "Request failed with exception #{e}"
    end
    response
  end
end
