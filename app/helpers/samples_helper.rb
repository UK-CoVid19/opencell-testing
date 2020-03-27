module SamplesHelper

  def get_badge(status)
    case Sample.states.to_hash[status]
    when Sample.states[:requested]
       return tag.span class: 'badge badge-pill badge-primary' do
         status
       end
    when Sample.states[:dispatched]
      return tag.span class: 'badge badge-pill badge-secondary' do
        status
      end
    when Sample.states[:received]
      return tag.span class: 'badge badge-pill badge-success' do
        status
      end
    when Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested],
        Sample.states[:analysed]
      return tag.span class: 'badge badge-pill badge-danger' do
        status
      end
    when Sample.states[:communicated]
      return tag.span class: 'badge badge-pill badge-warning' do
        status
      end
    when Sample.states[:rejected]
      return tag.span class: 'badge badge-pill badge-danger' do
        status
      end
    else
      raise
    end
  end

end
