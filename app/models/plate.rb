class UniqueWellPlateValidator < ActiveModel::Validator

  def validate(record)
    if record.wells.group_by { |w| [w.row, w.column] }.any? { |_, group| group.size != 1 }
      record.errors[:wells] << "Duplicate Well Found"
    end
    if record.wells.select {|x| x.sample_id != nil}.group_by { |w| w.sample_id }.any? { |_, group| group.size != 1 }
      record.errors[:plate] << "Duplicate Sample In plate Found"
    end
  end
end

class HasOtherErrorsValidator < ActiveModel::Validator

  def validate(record)
     if record.assign_error == true
        record.errors[:wells] << "Illegal Well Reference"
     end
  end
end

class Plate < ApplicationRecord

  extend QrModule

  has_many :wells, dependent: :destroy
  has_many :samples, through: :wells
  has_one :test, dependent: :destroy
  accepts_nested_attributes_for :wells
  enum state: %i[preparing prepared testing complete analysed]
  validates :wells, length: {maximum: 96, minimum: 96}
  qr_for :uid
  attr_accessor :assign_error
  validates_with UniqueWellPlateValidator, on: :create
  validates_with HasOtherErrorsValidator


  before_create :set_uid
  scope :is_preparing, -> {where(state: Plate.states[:preparing])}
  scope :is_prepared, -> {where(state: Plate.states[:prepared])}
  scope :is_testing, -> {where(state: Plate.states[:testing])}
  scope :is_complete, -> {where(state: Plate.states[:complete])}
  scope :is_done, -> {where(state: Plate.states[:analysed])}


  def self.build_plate
    plate = Plate.new
    wells = []
    PlateHelper.rows.each do |row|
      PlateHelper.columns.each do |column|
        wells << Well.new(row: row, column: column, plate: plate)
      end
    end
    plate.wells = wells
    plate
  end

  def set_uid
    self.uid = SecureRandom.uuid
  end

  def assign_samples(sample_mappings)
    sample_mappings.reject { |swm| swm[:id].blank? }.each do |mapping|
      sample = Sample.find(mapping[:id])
      well = wells.find { |w| w[:column] == mapping[:column].to_i && w[:row] == mapping[:row]}
      if (well.nil?)
        @assign_error = true
        break
      end

      well.sample = sample
      well.sample.state = Sample.states[:preparing]
    end
    self
  end

  def to_csv
    headers = %w{plate_id well_id well_row well_col sample_in_well}
    CSV.generate(headers: true) do |csv|
      csv << headers
      wells.each do |well|
        csv << [well.plate_id, well.id, well.row, well.column, !well.sample.nil?]
      end
    end
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