require 'rails_helper'

RSpec.describe "plates/show", type: :view do
  before(:each) do
    wells = build_list(:well, 96)
    @lab = create(:lab, labgroup: create(:labgroup))
    @plate = create(:plate, wells: wells, lab: @lab)
  end

  it "renders attributes in <p>" do
    render
  end
end
