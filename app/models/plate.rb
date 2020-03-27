class Plate < ApplicationRecord
  has_many :wells, dependent: :destroy
  has_many :samples, dependent: :nullify
  has_one :test, dependent: :destroy
  accepts_nested_attributes_for :wells
  enum state: %i[preparing prepared testing complete]
  validates :wells, length: {maximum: 96, minimum: 96}

  scope :is_preparing, -> {where(state: Plate.states[:preparing])}
  scope :is_prepared, -> {where(state: Plate.states[:prepared])}
  scope :is_testing, -> {where(state: Plate.states[:testing])}
  scope :is_complete, -> {where(state: Plate.states[:complete])}

end

module PlateHelper
  @@rows = ('A'..'H')
  @@columns = (1..12)

  def self.columns
    @@columns
  end

  def self.rows
    @@rows
  end
end