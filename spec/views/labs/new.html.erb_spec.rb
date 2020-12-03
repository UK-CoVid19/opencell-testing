require 'rails_helper'

RSpec.describe "labs/new", type: :view do
  before(:each) do
    assign(:lab, build(:lab))
  end

  it "renders new lab form" do
    render

    assert_select "form[action=?][method=?]", labs_path, "post" do
    end
  end
end
