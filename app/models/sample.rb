class Sample < ApplicationRecord

  extend QrModule

  qr_for :uid
  belongs_to :user
  has_many :records, dependent: :destroy
  has_one :well
  belongs_to :plate, optional: true
  validate :unique_well_in_plate?, on: :update, if: :well_id_changed?
  validate :check_valid_transition?, on: :update, if: :state_changed?
  validates :uid, uniqueness: true
  has_one :test_result, through: :well

  before_create :set_uid
  before_create :set_creation_record
  before_update :set_change_record, if: :state_changed?

  enum state: %i[ requested dispatched received preparing prepared tested analysed communicate rejected ]

  scope :is_requested, -> { where( :state => Sample.states[:requested]) }
  scope :is_dispatched, -> { where( :state => Sample.states[:dispatched]) }
  scope :is_received, -> { where( :state => Sample.states[:received]) }
  scope :is_preparing, -> { where( :state => Sample.states[:preparing]) }
  scope :is_prepared, -> { where( :state => Sample.states[:prepared]) }
  scope :is_tested, -> { where( :state => Sample.states[:tested]) }
  scope :is_analysed, -> { where( :state => Sample.states[:analysed]) }
  scope :is_communicated, -> { where( :state => Sample.states[:communicated]) }

  after_update :send_notification_after_analysis

  def self.block_user
    @with_user
  end

  def self.with_user(user, &block)
    @with_user = user
    begin
      yield block
    ensure
      @with_user = nil
    end
  end


  def self.tested_today
    Sample.joins(:records).where('records.state >= ? and records.created_at >= ?', Sample.states[:tested], Time.now.beginning_of_day).count
  end

  def self.requested_today
    Sample.joins(:records).where('records.state = ? and records.created_at >= ?', Sample.states[:requested], Time.now.beginning_of_day).count
  end

  def self.failure_rate
    Sample.joins(:records).where('records.state = ?', Sample.states[:rejected]).count / [Sample.all.count, 1].max
  end

  def self.average_testing_rate
    Sample.joins(:records).where('records.state >= ? and records.created_at >= ?', Sample.states[:tested], Time.now.beginning_of_day - 5.days).count / 5
  end

  private
  def unique_well_in_plate?
    return if plate.nil? or !well_id_changed?
    matched = plate.samples.find_by(id: id)
    if(matched)
      errors.add(:well, 'Sample exists in another well on this plate')
    end
  end

  def send_notification_after_analysis
      ResultNotifyJob.perform_later(self) if(self.saved_change_to_state? && self.analysed? && Rails.application.config.email_test_results)
  end

  def set_uid
    self.uid = SecureRandom.uuid
  end

  def check_valid_transition?
    valid =  valid_transition? state_was
    unless(valid)
      errors.add(:sample, "Cannot transition from #{state_was.to_s} to #{state.to_s}")
    end
  end

  def valid_transition? previous_state
    return true if Sample.states.to_hash[state] == Sample.states[:rejected]
    state_value = Sample.states[previous_state]
    (Sample.states[state] - state_value) == 1
  end

  def set_creation_record
    self.records << Record.new({user: Sample.block_user, note: nil, state: Sample.states[:requested]})
  end

  def set_change_record
    self.records << Record.new({user: Sample.block_user, note: nil, state: Sample.states[state]})
  end
end
