require 'rails_helper'

RSpec.describe Sample, type: :model do
  describe "update model" do

    before :each do
      @user = create(:user)
    end

    it "should not allow the state to transition to an invalid state" do
        Sample.with_user(@user) do
            @sample = create(:sample, state: Sample.states[:requested])
            @sample.state = Sample.states[:prepared]
            expect { @sample.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
    end

    Sample.states.each do |key, value|
      it "should allow any state to transition from #{key} to rejected" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: value)
          @sample.state = Sample.states[:rejected]
          expect { @sample.save! }.to_not raise_error
        end
      end
    end

    Sample.states.to_a[0, (Sample.states.size-1)].each do |key, value|
      it "should allow a state to transition from #{key} to the next state" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: value)
          @sample.state = value +1
          expect { @sample.save! }.to_not raise_error
        end
      end
    end

    describe "validations" do
      it "should have a unique UID via indifferent assignment" do
        new_sample = Sample.create(user: @user, uid: "abc")
        other_sample = Sample.create(user: @user, uid: "abc")
        expect(other_sample.uid).to eq new_sample.uid
      end

      it "should create a new UID if one is not provided" do
        new_sample = Sample.create(user: @user)
        other_sample = Sample.create(user: @user)
        expect(other_sample.uid).to_not eq new_sample.uid
      end 

      it "should validate that the sample can only be one well on the same plate" do
        # this is hacky because we don't validate the changes to be added on the wells, rather make an assocation on the plate. This is brittle and relies on the awful method in the controller
        plate = build(:plate, wells: 96.times.map {|t| build(:well)})
        plate.save
        @sample = nil
        Sample.with_user(@user) do
           @sample = create(:sample)
        end
        func = -> {Plate.transaction do
          @sample.plate = plate
          plate.samples << @sample
          plate.wells.first.sample = @sample
          plate.wells.second.sample = @sample
          plate.save!
        end}

        expect { func.call }.to raise_error(ActiveRecord::RecordInvalid)

      end
    end
  end
end
