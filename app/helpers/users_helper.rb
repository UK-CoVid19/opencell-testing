module UsersHelper
  def create_progress_bar(user)
    return 0 unless user.samples.any?

    case Sample.states.to_hash[user.samples.last.state]
    when Sample.states[:received]
      return 10
    when Sample.states[:preparing]
      return 20
    when Sample.states[:prepared]
      return 30
    when Sample.states[:tested]
      return 50
    when Sample.states[:analysed]
      return 75
    when Sample.states[:communicated]
      return 100
    else
      raise
    end
  end

  def create_state_alert(status)
    case Sample.states.to_hash[status]
    when Sample.states[:received]
      content_tag(:div, "We have received your sample and it is being processed", class: "alert alert-info")
    when Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested]
      content_tag(:div, "We are currently processing your sample", class: "alert alert-info")
    when Sample.states[:analysed]
      content_tag(:div, "We have generated your test results and are verifying them", class: "alert alert-info")
    when Sample.states[:communicated]
      content_tag(:div, "Your sample has been tested and analysed", class: "alert alert-info")
    else
      raise
    end
  end
end
