class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, presence: true
  validates :dob, presence: true
  validates :telno, presence: true
  validates :email, presence: true

  has_many :samples
  has_many :records

  enum role: [:patient, :staff]

  after_create :send_welcome_mail

  scope :patients, -> {where(role: User.roles[:patient])}



  def active_sample
    samples.last
  end

  def send_welcome_mail
    UserMailer.with(user: self).welcome_email.deliver_now
  end
end
