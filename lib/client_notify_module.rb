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

    url = URI.parse(client.url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    request['Accept'] = '*/*'
    client.headers.each do |header|
      request[header.key] = header.value
    end
    request.body = to_send.to_json

    response = nil
    begin
      response = http.request(request)
    rescue *ALL_NET_HTTP_ERRORS => e
      Rails.logger.error("Request failed with exception #{e}")
      raise NotifyException.new(e), "Request failed with exception #{e}"
    end
    response
  end
end
