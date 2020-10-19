class Header < ApplicationRecord
  belongs_to :client
  validates :key, presence: true, uniqueness: {scope: :client}
  validates :value, presence: true
end
