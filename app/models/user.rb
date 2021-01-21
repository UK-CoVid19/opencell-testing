class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable, :lockable, :session_limitable, :security_questionable

  validates :email, presence: true, email: true
  validates :password, password_strength: true, on: :create

  has_many :records, dependent: :destroy
  has_many :tests, dependent: :destroy
  has_many :plates

  belongs_to :security_question

  enum role: [:patient, :staff]

  after_create :send_welcome_mail, if: proc { |user| user.staff? }

  scope :patients, -> { where(role: User.roles[:patient]) }
  scope :staffmembers, -> { where(role: User.roles[:staff]) }

  def active_for_authentication?
    super && is_active?
  end

  def active_sample
    samples.last
  end

  private

  def send_welcome_mail
    UserMailer.with(user: self).welcome_email.deliver_now
  end

end
