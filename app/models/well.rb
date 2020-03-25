class Well < ApplicationRecord
  belongs_to :plate
  has_many :samples, dependent: :nullify
  accepts_nested_attributes_for :samples
end
