class UserMailer < ApplicationMailer

  def welcome_email
    @user = params[:user]
    mail(to: @user.email,
         subject: "Welcome to OpenCell Testing")
  end

  def staff_created_user
    @user = params[:user]
    mail(to: @user.email,
         subject: "Your Account Password")
  end
end
