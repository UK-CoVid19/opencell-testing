require 'rails_helper'

RSpec.describe "labgroups/index", type: :view do
  before(:each) do
    assign(:labgroups, create_list(:labgroup, 2))
  end

  it "renders a list of labgroups" do
    render
  end
end
