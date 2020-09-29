class TestResult < ApplicationRecord
  belongs_to :test
  belongs_to :well
  has_one :sample, through: :well
  enum state: { positive: 0, lowpositive: 1, negative: 2, inhibit: 3 }

  after_create :set_sample_status

  def set_sample_status
    well.sample.analysed!
    well.sample.save!
  end
end
