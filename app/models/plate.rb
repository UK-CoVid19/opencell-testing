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
      record.errors[:wells] << 'Illegal Well Reference'
    end
    if record.assign_control_error == true
      record.errors[:controls] << 'Control not checked'
    end
  end
end

class Plate < ApplicationRecord

  extend BarcodeModule

  has_many :wells, dependent: :destroy
  has_many :samples, through: :wells
  belongs_to :lab
  has_one :test, dependent: :destroy
  accepts_nested_attributes_for :wells
  enum state: %i[preparing prepared testing complete analysed]
  validates :wells, length: { maximum: 96, minimum: 96 }
  barcode_for :uid
  attr_accessor :assign_error, :assign_control_error
  validates_with UniqueWellPlateValidator, on: :create
  validates_with HasOtherErrorsValidator

  after_create :set_uid
  scope :is_preparing, -> { where(state: Plate.states[:preparing]) }
  scope :is_prepared, -> { where(state: Plate.states[:prepared]) }
  scope :is_testing, -> { where(state: Plate.states[:testing]) }
  scope :is_complete, -> { where(state: Plate.states[:complete]) }
  scope :is_done, -> { where(state: Plate.states[:analysed]) }
  scope :labgroup, ->(labgroup) { joins(lab: [:labgroup]).where(labs: { labgroups: {id: labgroup }}) }

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
    update(uid: "#{Date.today}-#{id}")
  end

  def assign_samples(sample_mappings)
    sample_mappings.reject { |swm| swm[:id].blank? && ActiveModel::Type::Boolean.new.cast(swm[:control]) == false }.each do |mapping|

      well = wells.find { |w| w[:column] == mapping[:column].to_i && w[:row] == mapping[:row]}
      if (well.nil?)
        @assign_error = true
        break
      end

      if PlateHelper.negative_extraction_controls.include?({row: well[:row], col: well[:column].to_i})
        if mapping[:control_code].to_i != Sample::CONTROL_CODE
          @assign_control_error = true
          break
        end
        sample = Sample.create!(client: Client.control_client, state: Sample.states[:preparing], control: true)
      elsif PlateHelper.auto_control_positions.include?({row: well[:row], col: well[:column].to_i})
        sample = Sample.create!(client: Client.control_client, state: Sample.states[:preparing], control: true)
      else
        sample = Sample.find(mapping[:id])
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

  def self.negative_extraction_controls
    [{ row: 'A', col: 1 }, { row: 'D', col: 6 }, { row: 'E', col: 6 }, { row: 'E', col: 12 }]
  end

  def self.auto_control_positions
    [{ row: 'F', col: 12 }, { row: 'G', col: 12 }, { row: 'H', col: 12 }]
  end

  def self.control_positions
    negative_extraction_controls + auto_control_positions
  end
end
