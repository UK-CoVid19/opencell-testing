require 'rails_helper'

RSpec.describe "plates/new", type: :view do
  before(:each) do
    assign(:plate, Plate.new())
  end

  it "renders new plate form" do
    render

    assert_select "form[action=?][method=?]", plates_path, "post" do
    end
  end
end
