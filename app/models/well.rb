class Well < ApplicationRecord
  belongs_to :plate
  has_many :samples
end
