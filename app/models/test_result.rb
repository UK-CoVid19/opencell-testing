class TestResult < ApplicationRecord
  belongs_to :test
  belongs_to :well
  has_one :sample, through: :well
  validates :value, presence: true

  enum state: %i[ positive lowpositive negative inhibit]

  after_create :set_sample_status

  def set_sample_status
    well.sample.analysed!
    well.sample.save!
  end

end
