require 'rails_helper'

RSpec.describe "plates/edit", type: :view do
  before(:each) do
    wells = build_list(:well, 96)
    @plate = create(:plate, wells: wells )
  end

  it "renders the edit plate form" do
    render

    assert_select "form[action=?][method=?]", plate_path(@plate), "post" do
    end
  end
end
