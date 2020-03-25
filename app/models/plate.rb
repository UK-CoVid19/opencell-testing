class Plate < ApplicationRecord
  has_many :wells, dependent: :destroy
  has_many :samples, dependent: :nullify
  accepts_nested_attributes_for :wells
  enum state: %i[preparing prepared testing complete]
  validates :wells, length: {maximum: 96}

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