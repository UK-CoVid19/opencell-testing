class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :email, presence: true, email: true
  validates :api_key, uniqueness: true, allow_nil: true

  has_many :samples, dependent: :destroy
  has_many :records, dependent: :destroy
  has_one :test, dependent: :destroy

  enum role: [:patient, :staff]

  after_create :send_welcome_mail, if: proc { |user| user.staff? }
  before_create :hash_api_key, if: proc { |user| user.patient? }

  scope :patients, -> { where(role: User.roles[:patient]) }
  scope :staffmembers, -> { where(role: User.roles[:staff]) }

  def active_sample
    samples.last
  end

  private

  def send_welcome_mail
    UserMailer.with(user: self).welcome_email.deliver_now
  end

  def hash_api_key
    raise if api_key.blank?

    self.api_key = Digest::SHA256.base64digest(api_key.encode('UTF-8'))
  end

end
