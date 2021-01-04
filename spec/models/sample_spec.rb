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
        expect(@sample.uid).to eq @retest.uid
        expect(@retest.uid).to eq uid
        expect(@sample.client).to eq @retest.client
        expect(@sample.is_retest).to eq false
        expect(@retest.is_retest).to eq true
      end
    end

    it "should not let a sample have more than one retest" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:tested])
        @retest = @sample.create_retest(Rerun::INCONCLUSIVE)
        @sample.reload
        expect { @sample.create_retest(Rerun::INCONCLUSIVE) }.to raise_error "Retest already exists"
      end
    end

    it "should not let a retest be retested" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: Sample.states[:tested])
        @retest = @sample.create_retest(Rerun::INCONCLUSIVE)
        expect { @retest.create_retest(Rerun::INCONCLUSIVE) }.to raise_error "Sample is a rerun"
      end
    end

    it "should create a rerun with the correct directional associations" do
      Sample.with_user(@user) do
        @sample_s = create(:sample, state: Sample.states[:tested])
        @retest = @sample_s.create_retest(Rerun::INCONCLUSIVE)
        @sample_s.reload
        expect(@retest).to_not be nil
        expect(@sample_s.retest).to eq @retest
        expect(@sample_s.retest?).to eq true
        expect(@retest.source_sample).to eq @sample_s
        expect(@sample_s.rerun.reason).to eq Rerun::INCONCLUSIVE
      end
    end

    [[false,true], [true,false]].each do |a, b|
      it "should allow the same UID if the retest flag is different" do
        Sample.with_user(@user) do
          @sample_a = create(:sample, state: Sample.states[:tested], uid: 'abc', is_retest: a)
          @sample_b_attribs = build(:sample, state: Sample.states[:tested], uid: 'abc', is_retest: b).attributes
          expect { Sample.create!(@sample_b_attribs) }.to_not raise_error
        end
      end
    end

    [false, true].each do |b|
      it "should not allow the same UID if the retest flag is the same" do
        Sample.with_user(@user) do
          @sample_a = create(:sample, state: Sample.states[:tested], uid: 'abc', is_retest: b, client: @client)
          @sample_b_attribs = build(:sample, state: Sample.states[:tested], uid: 'abc', is_retest: b, client: @client).attributes
          expect { Sample.create!(@sample_b_attribs) }.to raise_error ActiveRecord::RecordInvalid
        end
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
      Sample.with_user(@user) do
        @sample = create(:sample)
        expect { @sample.reject! }.to have_enqueued_job(RejectionJob)
      end
    end

    it "should enqueue a notification job on setting to communicated" do
      Sample.with_user(@user) do
        @sample = create(:sample, state: :received)
        @sample.preparing!
        @sample.prepared!
        @sample.tested!
        @sample.analysed!
        expect { @sample.communicated! }.to have_enqueued_job(ResultNotifyJob)
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

    describe "posthoc retests" do
      it "should create a retest of a valid communicated sample" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: :received, client: @client)
          @sample.preparing!
          @sample.preparing!
          @sample.prepared!
          @sample.tested!
          @sample.analysed!
          @sample.communicated!
          @sample.commcomplete!

          @retest = @sample.create_posthoc_retest(Rerun::POSITIVE)
        end
        expect(@retest.uid).to eq @sample.uid
        expect(@retest.state).to eq "received"
        expect(@sample.state).to eq "retest"
        expect(@retest.source_sample).to eq @sample
        expect(@retest.rerun_for.source_sample).to eq @sample
      end

      it "should not create a rerun of a sample that has not been communicated already" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: :received, client: @client)
          @rerun = @sample.create_retest(Rerun::POSITIVE)
          expect { @rerun.create_posthoc_retest(Rerun::POSITIVE) }.to raise_error "Sample is a rerun"
        end
      end

      it "should not allow an internal rerun of a rerun" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: :received, client: @client)
          expect {@sample.create_posthoc_retest(Rerun::POSITIVE)}.to raise_error "Sample cannot be retested unless communicated"
        end
      end
    end

    describe "validations" do
      it "should not allow duplicate ID" do
        Sample.with_user(@user) do
          new_sample = create(:sample, client: @client, uid: "abc")
          other_sample = build(:sample,client: @client, uid: "abc")
          expect(other_sample.save).to be false
        end
      end
      it "should  allow duplicate ID if retest" do
        Sample.with_user(@user) do
          new_sample = create(:sample, client: @client, uid: "abc")
          other_sample = build(:sample,client: @client, uid: "abc", is_retest: true)
          expect(other_sample.save).to be true
        end
      end

      it "should allow duplicate ID if the client is different" do
        Sample.with_user(@user) do
          new_sample = create(:sample, client: @client, uid: "abc")

          @second_client = create(:client)

          other_sample = build(:sample, client: @second_client, uid: "abc")
          other_sample.save
          puts other_sample.errors.full_messages
          expect(other_sample.save).to be true
        end
      end

      it "should create a new UID if one is not provided" do
        Sample.with_user(@user) do
          new_sample = create(:sample, client: @client)
          other_sample = create(:sample, client: @client)
          expect(other_sample.uid).to_not eq new_sample.uid
        end
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

    describe "rejections" do
      it "should not allow rejections if the sample has already been rejected" do
        Sample.with_user(@user) do
          @sample = create(:sample, state: :received, client: @client)
          @sample.rejected!
          expect(@sample.rejectable?).to eq false
        end
      end

      it "should not allow rejections if the sample is associated with a plate" do
        Sample.with_user(@user) do
          @plate = Plate.build_plate
          @plate.user = create(:user)
          @sample = create(:sample, state: :received, client: @client)
          @plate.wells.first.sample = @sample
          @plate.save!
          @sample.reload
          expect(@sample.rejectable?).to eq false
        end
      end

      it "should throw reject if sample isn't rejectable" do
        Sample.with_user(@user) do
          @plate = Plate.build_plate
          @plate.user = create(:user)
          @sample = create(:sample, state: :received, client: @client)
          @plate.wells.first.sample = @sample
          @plate.save!
          @sample.reload
          expect { @sample.reject! }.to raise_error "Cannot Reject Sample #{@sample.id}"
        end
      end
    end
  end
end
