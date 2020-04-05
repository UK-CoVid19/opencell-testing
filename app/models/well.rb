class Well < ApplicationRecord
  belongs_to :plate
  has_one :sample, dependent: :nullify
  has_one :test_result, dependent: :destroy
  accepts_nested_attributes_for :sample
end
