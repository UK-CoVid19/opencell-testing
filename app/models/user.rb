class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :name, presence: true
  validates :dob, presence: true
  validates :telno, presence: true
  validates :email, presence: true
  validates :api_key, uniqueness: :true

  has_many :samples, dependent: :destroy
  has_many :records, dependent: :destroy
  has_one :test, dependent: :destroy

  enum role: [:patient, :staff]

  after_create :send_welcome_mail
  before_create :set_api_key

  scope :patients, -> {where(role: User.roles[:patient])}
  scope :staffmembers, -> {where(role: User.roles[:staff])}


  def active_sample
    samples.last
  end
  private
  def send_welcome_mail
    UserMailer.with(user: self).welcome_email.deliver_now
  end

  def set_api_key
    self.api_key = SecureRandom.base64(16)
  end


end
