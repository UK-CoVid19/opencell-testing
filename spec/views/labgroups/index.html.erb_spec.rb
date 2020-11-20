require 'rails_helper'

RSpec.describe "labgroups/index", type: :view do
  before(:each) do
    assign(:labgroups, [
      Labgroup.create!(),
      Labgroup.create!()
    ])
  end

  it "renders a list of labgroups" do
    render
  end
end
