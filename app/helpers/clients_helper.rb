module ClientsHelper
  def get_headers(client)
    return client.headers if client.headers.any?
    [Header.new]
  end
end
