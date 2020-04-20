class Well < ApplicationRecord
  belongs_to :plate, inverse_of: :wells
  belongs_to :sample, optional: true
  has_one :test_result, dependent: :destroy
  accepts_nested_attributes_for :sample
  validates :sample, uniqueness: true, allow_nil: true
end
