module UsersHelper
    def create_progress_bar(user)
        return 0 unless user.samples.any?

        status = user.samples.last.state
        case Sample.states.to_hash[status]
        when Sample.states[:requested]
            return 10
        when Sample.states[:dispatched]
            return 20
        when Sample.states[:received]
            return 30
        when Sample.states[:preparing],
            Sample.states[:prepared],
            Sample.states[:tested]
            return 50
        when Sample.states[:analysed]
            return 75
        when Sample.states[:communicated], Sample.states[:commcomplete]
            return 100
        when Sample.states[:rejected], Sample.states[:commfailed]
            return 100
        else
            raise
        end
    end


    def create_state_alert(status)
        case Sample.states.to_hash[status]
        when Sample.states[:requested]
            return content_tag(:div, "You have requested your sample, we will notify you when it is dispatched", class: "alert alert-info" )
        when Sample.states[:dispatched]
            return content_tag(:div, "Your sample has been dispatched, please return it as soon as possible", class: "alert alert-info" )
        when Sample.states[:received]
            return content_tag(:div, "We have received your sample and it is being processed", class: "alert alert-info" )
        when Sample.states[:preparing],
            Sample.states[:prepared],
            Sample.states[:tested]
            return content_tag(:div, "We are currently processing your sample", class: "alert alert-info" )
        when Sample.states[:analysed]
            return content_tag(:div, "We have generated your test results and are verifying them", class: "alert alert-info" )
        when Sample.states[:communicated]
            return content_tag(:div, "Your sample has been tested and analysed", class: "alert alert-info" )
        when Sample.states[:commcomplete]
            return content_tag(:div, "Your result has been reported", class: "alert alert-info" )
        when Sample.states[:commfailed]
            return content_tag(:div, "Your result failed to report", class: "alert alert-warning" )
        when Sample.states[:rejected]
            return content_tag(:div, "Your result has been rejected", class: "alert alert-warning" )
        else
            raise
        end
    end
end
