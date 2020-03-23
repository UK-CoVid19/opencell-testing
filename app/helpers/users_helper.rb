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
                Sample.states[:tested],
                Sample.states[:analysed]
                return 50
            when Sample.states[:communicated]
                return 100
            else
                raise
        end
    end
end
