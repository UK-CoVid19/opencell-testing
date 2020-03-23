class ResultMailer < ApplicationMailer

  default from: 'info@opencell.bio'

  def results_email
    @sample = params[:sample]
    @user = @sample.user
    mail(to: @user.email, subject: 'Test Results')
  end

end
