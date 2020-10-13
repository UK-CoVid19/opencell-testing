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

  def make_request(to_send, opts = {})

    url = URI.parse(opts.url ||= ENV['NOTIFY_URL'])
    username = opts.username ||= ENV['NOTIFY_USERNAME']
    password = opts.password ||= ENV['NOTIFY_PASSWORD']
    apikey = opts.apikey ||= ENV['NOTIFY_API_KEY']
    authorization = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url, 'Content-Type' => 'application/json')
    request['Accept'] = '*/*'
    request['Authorization'] = authorization
    request['apikey'] = apikey
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
