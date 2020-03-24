class Well < ApplicationRecord
  belongs_to :plate
  has_many :samples
  accepts_nested_attributes_for :samples
end
