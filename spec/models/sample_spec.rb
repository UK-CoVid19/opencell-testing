require 'rails_helper'

RSpec.describe Sample, type: :model do
  describe "update model" do
    before :each do
      @user = create(:user)
      @client = create(:client)
    end

    it "should not allow the state to transition to an invalid state" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:requested])
        @sample.state = Sample.states[:prepared]
        expect { @sample.save! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it "should create a valid retest" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:tested])
        uid = @sample.uid
        @retest = @sample.create_retest(Rerun::INCONCLUSIVE)
        expect(@sample.state).to eq "retest"
        expect(@retest.state).to eq "received"
        expect(@sample.retest).to eq @retest
        expect(@retest.persisted?).to eq true
        expect(@sample.uid).to eq "#{uid}-r"
        expect(@retest.uid).to eq uid
        expect(@sample.client).to eq @retest.client
      end
    end

    it "should create a rerun with the correct directional associations" do
      Sample.with_user(@user) do
        @sample_s = create(:sample, state: Sample.states[:tested])
        @retest = @sample_s.create_retest(Rerun::INCONCLUSIVE)
        expect(@retest).to_not be nil
        expect(@sample_s.retest).to eq @retest
        expect(@sample_s.retest?).to eq true
        expect(@retest.source_sample).to eq @sample
        expect(@sample_s.rerun.reason).to eq Rerun::INCONCLUSIVE
      end
    end

    it "should create a record with the initial state of received" do
      Sample.with_user(@user) do
        @sample = Sample.new(client: @client, state: Sample.states[:received])
        expect { @sample.save! }.to_not raise_error
        expect(@sample.state).to eq :received.to_s
        expect(@sample.records.size).to eq 1
        expect(@sample.records.last.state).to eq Sample.states[:received]
      end
    end

    it "should  allow the state to transition from commfailed to commcomplete" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:commfailed])
        @sample.state = Sample.states[:commcomplete]
        expect { @sample.save! }.to_not raise_error
      end
    end

    it "should allow the state to transition from communicated to commfailed" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:communicated])
        @sample.state = Sample.states[:commfailed]
        expect { @sample.save! }.to_not raise_error
      end
    end

    it "should preferentially select a user which is set on the instance rather than the class" do
      @other_user = create(:user)
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:communicated])
        @sample.with_user(@other_user) do |s|
          s.state = Sample.states[:commfailed]
          expect { s.save! }.to_not raise_error
          expect(s.records.last.user).to eq @other_user
        end
        expect(@sample.records.last.user).to eq @other_user
      end
    end

    it "should not require a class user to be set if an instance user is supplied" do
      @other_user = create(:user)
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:communicated])
      end
      Sample.with_user(nil) do
        @sample.with_user(@other_user) do |s|
          s.state = Sample.states[:commfailed]
          expect { s.save! }.to_not raise_error
        end
      end
      expect(@sample.records.last.user).to eq @other_user
    end

    it "should be invalid if no user has been set" do
      @other_user = create(:user)
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:communicated])
      end
      Sample.with_user(nil) do
        @sample.state = Sample.states[:commfailed]
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

    it "should enqueue a rejection job on rejection" do
      Rails.application.config.send_test_results = true
      Sample.with_user(@user) do
        @sample = create(:sample)
        expect { @sample.rejected! }.to have_enqueued_job(RejectionJob)
      end
    end

    it "should not enqueue a rejection job on rejection if sending disabled" do
      Rails.application.config.send_test_results = false
      Sample.with_user(@user) do
        @sample = create(:sample)
        expect { @sample.rejected! }.to_not have_enqueued_job(RejectionJob)
      end
    end

    [:commcomplete, :commfailed].each do |state|
      it "should allow a rejected sample to transition to communication states" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: :rejected)
          @sample.state = Sample.states[state]
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
      it "should not allow duplicate ID" do
        new_sample = Sample.create(client: @client, uid: "abc")
        other_sample = Sample.new(client: @client, uid: "abc")
        expect(other_sample.save).to be false
      end

      it "should create a new UID if one is not provided" do
        new_sample = Sample.create(client: @client)
        other_sample = Sample.create(client: @client)
        expect(other_sample.uid).to_not eq new_sample.uid
      end

      it "should validate that the sample can only be one well on the same plate" do
        # this is hacky because we don't validate the changes to be added on the wells, rather make an assocation on the plate. This is brittle and relies on the awful method in the controller
        plate = build(:plate, wells: 96.times.map { |t| build(:well) })
        plate.save
        @sample = nil
        Sample.with_user(@user) do
          @sample = create(:sample)
        end
        func = lambda {
          Plate.transaction do
            @sample.plate = plate
            plate.samples << @sample
            plate.wells.first.sample = @sample
            plate.wells.second.sample = @sample
            plate.save!
          end
        }

        expect { func.call }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
