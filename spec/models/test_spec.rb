require 'rails_helper'

RSpec.describe Test, type: :model do
  it "should validate that a plate can only be tested once" do
    wells = build_list(:well, 96)
    @labgroup = create(:labgroup)
    @plate = create(:plate, wells: wells, lab: @labgroup.labs.first)
    @test = create(:test, plate: @plate)

    @test_2 = build(:test, plate: @plate)

    expect(@test_2.save).to eq false
    expect(@test_2.errors.messages[:plate_id].first).to eq 'has already been taken'
    expect(@test_2.errors.details[:plate_id].first[:error]).to eq :taken
  end

  it "should validate that a plate needs a user" do
    wells = build_list(:well, 96)
    @labgroup = create(:labgroup)
    @plate = create(:plate, wells: wells, lab: @labgroup.labs.first)
    @test = build(:test, plate: @plate, user: nil)

    expect(@test.save).to eq false
    expect(@test.errors.messages[:user].first).to eq 'must exist'
  end
end
