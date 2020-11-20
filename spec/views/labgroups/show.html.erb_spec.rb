require 'rails_helper'

RSpec.describe "labgroups/show", type: :view do
  before(:each) do
    @labgroup = assign(:labgroup, Labgroup.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
