require 'rails_helper'

RSpec.describe "labgroups/new", type: :view do
  before(:each) do
    assign(:labgroup, Labgroup.new())
  end

  it "renders new labgroup form" do
    render

    assert_select "form[action=?][method=?]", labgroups_path, "post" do
    end
  end
end
