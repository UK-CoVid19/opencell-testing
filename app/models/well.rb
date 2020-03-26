class Well < ApplicationRecord
  belongs_to :plate
  has_one :sample
  accepts_nested_attributes_for :sample
end
