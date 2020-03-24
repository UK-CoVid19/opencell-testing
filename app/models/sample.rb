class Sample < ApplicationRecord
  belongs_to :user
  has_many :records

  enum state: %i[requested dispatched received preparing prepared tested analysed communicated]

  scope :is_requested, -> {where(:state => Sample.states[:requested])}
  scope :is_dispatched, -> {where(:state => Sample.states[:dispatched])}
  scope :is_received, -> {where(:state => Sample.states[:received])}
  scope :is_preparing, -> {where(:state => Sample.states[:preparing])}
  scope :is_prepared, -> {where(:state => Sample.states[:prepared])}
  scope :is_tested, -> {where(:state => Sample.states[:tested])}
  scope :is_analysed, -> {where(:state => Sample.states[:analysed])}
  scope :is_communicated, -> {where(:state => Sample.states[:communicated])}

  after_update :send_notification_after_analysis


  def send_notification_after_analysis
      ResultNotifyJob.perform_later(self) if(self.saved_change_to_state? && self.analysed?)
  end
end
