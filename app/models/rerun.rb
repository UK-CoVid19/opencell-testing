class Rerun < ApplicationRecord
  belongs_to :source_sample, class_name: "Sample", foreign_key: :sample_id
  belongs_to :retest, class_name: "Sample", foreign_key: :retest_id
  accepts_nested_attributes_for :retest
  validates :reason, presence: true, inclusion: {in: ["Positive", "Inconclusive"]}
  POSITIVE = "Positive"
  INCONCLUSIVE = "Inconclusive"

  REASONS = [POSITIVE, INCONCLUSIVE]
end
