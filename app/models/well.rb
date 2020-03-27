class Well < ApplicationRecord
  belongs_to :plate
  has_one :sample
  has_one :test_result
  accepts_nested_attributes_for :sample
end
