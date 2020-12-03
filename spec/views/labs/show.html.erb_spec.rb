require 'rails_helper'

RSpec.describe "labs/show", type: :view do
  before(:each) do
    @group = create(:labgroup)
    @lab = assign(:lab, create(:lab, labgroup: @group))
  end

  it "renders attributes in <p>" do
    render
  end
end
