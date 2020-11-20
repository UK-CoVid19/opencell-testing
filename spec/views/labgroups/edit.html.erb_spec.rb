require 'rails_helper'

RSpec.describe "labgroups/edit", type: :view do
  before(:each) do
    @labgroup = assign(:labgroup, Labgroup.create!())
  end

  it "renders the edit labgroup form" do
    render

    assert_select "form[action=?][method=?]", labgroup_path(@labgroup), "post" do
    end
  end
end
