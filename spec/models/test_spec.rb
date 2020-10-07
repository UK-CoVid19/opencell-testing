require 'rails_helper'

RSpec.describe Test, type: :model do
  it "should validate that a plate can only be tested once" do
    wells = build_list(:well, 96)
    @plate = create(:plate, wells: wells)
    @test = create(:test, plate: @plate)

    @test_2 = build(:test, plate: @plate)

    expect(@test_2.save).to eq false
    expect(@test_2.errors.messages[:plate_id].first).to eq 'has already been taken'
    expect(@test_2.errors.details[:plate_id].first[:error]).to eq :taken
  end  
end
