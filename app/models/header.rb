class Header < ApplicationRecord
  belongs_to :client
  validates :key, presence: true
  validates :value, presence: true
end
