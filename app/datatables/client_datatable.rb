
class ClientDatatable < SampleDatatable

  def initialize(params, opts = {})
    @client = opts[:client]
    super
  end

  def get_raw_records
    policy_scope(@client.samples)
  end
end
