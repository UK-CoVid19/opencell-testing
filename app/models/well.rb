class Well < ApplicationRecord
  belongs_to :plate, inverse_of: :wells
  has_one :sample, dependent: :nullify
  has_one :test_result, dependent: :destroy
  accepts_nested_attributes_for :sample
end
