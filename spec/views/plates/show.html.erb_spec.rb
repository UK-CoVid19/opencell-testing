require 'rails_helper'

RSpec.describe "plates/show", type: :view do
  before(:each) do
    wells = build_list(:well, 96)
    @plate = create(:plate, wells: wells )
  end

  it "renders attributes in <p>" do
    render
  end
end
