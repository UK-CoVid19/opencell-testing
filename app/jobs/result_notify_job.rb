class ResultNotifyJob < ApplicationJob
  queue_as :default

  def perform(sample)
    # Send email to user, send twilio SMS to user
    ResultMailer.with(sample: sample).results_email.deliver_later
  end
end