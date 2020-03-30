require 'rqrcode'

class Plate < ApplicationRecord
  has_many :wells, dependent: :destroy
  has_many :samples, dependent: :nullify
  has_one :test, dependent: :destroy
  accepts_nested_attributes_for :wells
  enum state: %i[preparing prepared testing complete]
  validates :wells, length: {maximum: 96, minimum: 96}


  before_create :set_uid

  scope :is_preparing, -> {where(state: Plate.states[:preparing])}
  scope :is_prepared, -> {where(state: Plate.states[:prepared])}
  scope :is_testing, -> {where(state: Plate.states[:testing])}
  scope :is_complete, -> {where(state: Plate.states[:complete])}


  def set_uid
    self.uid = SecureRandom.uuid
  end

  def qr_code
    qrcode = RQRCode::QRCode.new(uid)
    png = qrcode.as_png(
        bit_depth: 1,
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,
        color: 'black',
        file: nil,
        fill: 'white',
        module_px_size: 6,
        resize_exactly_to: false,
        resize_gte_to: false,
        size: 400
    )
    return png
  end

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