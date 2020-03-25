class Sample < ApplicationRecord
  belongs_to :user
  has_many :records, dependent: :destroy
  belongs_to :well, optional: true
  belongs_to :plate, optional: true
  validate :unique_well_in_plate?, on: :update


  enum state: %i[requested dispatched received preparing prepared tested analysed communicate rejected]

  scope :is_requested, -> {where(:state => Sample.states[:requested])}
  scope :is_dispatched, -> {where(:state => Sample.states[:dispatched])}
  scope :is_received, -> {where(:state => Sample.states[:received])}
  scope :is_preparing, -> {where(:state => Sample.states[:preparing])}
  scope :is_prepared, -> {where(:state => Sample.states[:prepared])}
  scope :is_tested, -> {where(:state => Sample.states[:tested])}
  scope :is_analysed, -> {where(:state => Sample.states[:analysed])}
  scope :is_communicated, -> {where(:state => Sample.states[:communicated])}

  after_update :send_notification_after_analysis

  private
  def unique_well_in_plate?
    return if plate.nil?
    matched = plate.samples.find_by(id: id)
    if(matched)
      errors.add(:well, 'Sample exists in another well on this plate')
    end
  end

  def send_notification_after_analysis
      ResultNotifyJob.perform_later(self) if(self.saved_change_to_state? && self.analysed?)
  end
end
