module SamplesHelper

  def get_badge(status)
    case Sample.states.to_hash[status]
    when Sample.states[:requested], Sample.states[:dispatched],
        Sample.states[:received],
        Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested],
        Sample.states[:analysed],
        Sample.states[:communicated]
      return status.capitalize
    when Sample.states[:rejected]
      return tag.span class: 'badge badge-pill badge-danger' do
        status.capitalize
      end
    else
      raise
    end
  end

end
