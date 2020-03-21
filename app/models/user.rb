class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum role: [:patient, :staff]

  after_create :send_welcome_mail


  def send_welcome_mail
    UserMailer.with(user: self).welcome_email.deliver_now
  end
end
