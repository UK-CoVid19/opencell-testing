require 'rails_helper'
RSpec.describe Plate, type: :model do

  describe "build_plate" do
    before :each do
      @labgroup = create(:labgroup)
    end

    it "Should create a valid plate with valid number of empty wells" do
      plate =  Plate.build_plate
      plate.lab = @labgroup.labs.first
      expect(plate.save).to be true
      expect(plate.wells.size).to be 96
      expect(plate.samples.size).to be 0
    end

    it "Should create a valid plate with a correct UID" do
      plate =  Plate.build_plate
      plate.lab = @labgroup.labs.first
      expect(plate.save).to be true
      expect(plate.uid).to eq "#{Date.today}-#{plate.id}"
    end

    it "Should not create a plate with insufficient wells" do
      plate =  Plate.new
      plate.lab = @labgroup.labs.first
      wells = []
      PlateHelper.columns.first(11).each do |col|
        PlateHelper.rows.each do |row|
          wells << Well.new(row: row, column: col, plate: plate)
        end
      end
      expect(plate.save).to be false
      expect(plate.errors.size).to eq 1
      expect(plate.errors[:wells].size).to eq 1
      expect(plate.errors[:wells].first.include? 'too short')
    end

    it "Should not create a plate with insufficient wells" do
      plate =  Plate.new
      plate.lab = @labgroup.labs.first
      wells = []
      PlateHelper.columns.to_a.concat([13]).each do |col|
        PlateHelper.rows.each do |row|
          wells << Well.new(row: row, column: col, plate: plate)
        end
      end
      expect(plate.save).to be false
      expect(plate.errors.size).to eq 1
      expect(plate.errors[:wells].size).to eq 1
      expect(plate.errors[:wells].first.include? 'too long')
    end

    it "Should not create a plate with duplicate wells" do
      plate =  Plate.new
      plate.lab = @labgroup.labs.first
      wells = []
      # should create G1-12
      ('A'..'G').to_a.concat(['G']).each do |row|
        PlateHelper.columns.each do |col|
          wells << Well.new(row: row, column: col, plate: plate)
        end
      end
      plate.wells = wells
      expect(plate.save).to be false
      expect(plate.errors.size).to eq 1
      expect(plate.errors[:wells].size).to eq 1
      expect(plate.errors[:wells].first.include? 'Duplicate Well')
    end
  end

  describe "Assign Samples" do

    before :each do
      @labgroup = create(:labgroup)
    end

    it "should assign a valid sample to a well on a plate" do

      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        sample_mappings = [{id: @sample.id, row: plate.wells.third.row, column: plate.wells.third.column}]
        this_plate = plate.assign_samples(sample_mappings)
        expect(this_plate.save).to be true
        expect(this_plate.wells.third.sample).to eq @sample.reload
        expect(Sample.states[this_plate.wells.third.sample.state]).to eq Sample.states[:preparing]
      end
    end

    it "should not be able to assign a sample to 2 wells" do

      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        sample_mappings = [ {id: @sample.id, row: plate.wells.third.row, column: plate.wells.third.column}, {id: @sample.id, row: plate.wells.second.row, column: plate.wells.second.column} ]
        this_plate = plate.assign_samples(sample_mappings)
        expect(this_plate.save).to be false
        expect(this_plate.errors.size).to eq 1
        expect(this_plate.errors[:plate].size).to eq 1
        expect(this_plate.errors[:plate].first.include? 'Duplicate Sample In plate Found')
      end
    end

    it "should handle a nil sample id" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        sample_mappings = [{id: nil, row: plate.wells.third.row, column: plate.wells.third.column, control: false}]
        this_plate = plate.assign_samples(sample_mappings)
        expect(this_plate.save).to be true
        expect(this_plate.wells.third.sample).to be nil
      end
    end

    it "should handle an empty sample id" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        sample_mappings = [{id: "", row: plate.wells.third.row, column: plate.wells.third.column, control: false}]
        this_plate = plate.assign_samples(sample_mappings)
        expect(this_plate.save).to be true
        expect(this_plate.wells.third.sample).to be nil
      end
    end

    it "should throw on a nil row" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        sample_mappings = [{id: @sample.id, row: nil, column: plate.wells.third.column}]
        expect(plate.assign_samples(sample_mappings).assign_error).to be true
        expect(plate.assign_samples(sample_mappings).valid?).to be false
      end
    end

    it "should throw on a nil column" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        sample_mappings = [{id: @sample.id, row: plate.wells.third.row, column: nil}]
        expect(plate.assign_samples(sample_mappings).assign_error).to be true
        expect(plate.assign_samples(sample_mappings).valid?).to be false
      end
    end

    it "should handle a valid control sample" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        control_position = PlateHelper.control_positions.first
        sample_mappings = [{id: nil, column: control_position[:col], row: control_position[:row], control: true, control_code: Sample::CONTROL_CODE}]
        expect(plate.assign_samples(sample_mappings).valid?).to be true
      end
    end

    it "should reject an invalid control sample" do
      Sample.with_user(create(:user, role: User.roles[:staff])) do
        plate = Plate.build_plate
        plate.lab = @labgroup.labs.first
        @sample = create(:sample, state: Sample.states[:received])
        control_position = PlateHelper.control_positions.first
        sample_mappings = [{id: nil, column: control_position[:col], row: control_position[:row], control: true, control_code: 'WRONG CODE'}]
        expect(plate.assign_samples(sample_mappings).valid?).to be false
      end
    end
  end

end
