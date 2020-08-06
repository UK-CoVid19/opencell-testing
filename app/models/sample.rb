
class Sample < ApplicationRecord

  extend QrModule

  qr_for :uid
  belongs_to :user
  has_many :records, dependent: :destroy
  has_one :well, dependent: :nullify
  belongs_to :plate, optional: true
  validate :unique_well_in_plate?, on: :update, if: :well_id_changed?
  validate :check_valid_transition?, on: :update, if: :state_changed?
  validates :uid, uniqueness: true
  has_one :test_result, through: :well

  before_create :set_uid, unless: :uid?
  before_create :set_creation_record
  before_update :set_change_record, if: :state_changed?

  enum state: %i[ requested dispatched received preparing prepared tested analysed communicated rejected ]

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

  def self.tested_last_week
    samples = Sample
        .select("date(samples.created_at) as created_date, count(samples.id) as count")
        .where('samples.state >= ? and samples.created_at >= ?', Sample.states[:tested], 7.days.ago.beginning_of_day)
        .group("date(samples.created_at)")
        .order('created_date DESC')
    unless samples.any?
      return self.dummy
    end
    samples
  end

  def self.total_tests
    where('samples.state >= ?', Sample.states[:analysed]).count
  end

  def self.requested_last_week
    # all samples that were created in the last week
    samples = Sample
        .select("date(samples.created_at) as created_date, count(samples.id) as count")
        .where('samples.created_at >= ?', 7.days.ago.beginning_of_day)
        .group("date(samples.created_at)")
        .order('created_date DESC')
    unless samples.any?
      return self.dummy
    end
    samples
  end


  def self.failure_rate_last_week
    samples = Sample
        .select("date(samples.created_at) as created_date, cast(count(CASE WHEN samples.state = #{Sample.states[:rejected]} THEN 1 END) as decimal) / count(*) as count")
        .where('samples.created_at >= ?', 7.days.ago.beginning_of_day)
        .group("date(samples.created_at)")
        .order('created_date DESC')
    unless samples.any?
      return self.dummy
    end
    samples
  end


  private
  def unique_well_in_plate?
    return if plate.nil? or !well_id_changed?
    matched = plate.samples.find_by(id: id)
    if(matched)
      errors.add(:well, 'Sample exists in another well on this plate')
    end
  end

  def self.dummy
    return [{count: 0}, {count: 0}]
  end

  def send_notification_after_analysis
      ResultNotifyJob.perform_later(self) if(self.saved_change_to_state? && self.communicated? && Rails.application.config.email_test_results)
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
