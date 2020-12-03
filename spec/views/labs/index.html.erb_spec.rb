require 'rails_helper'

RSpec.describe "labs/index", type: :view do
  before(:each) do
    @labgroup = create(:labgroup)
    assign(:labs, [
      create(:lab, labgroup: @labgroup),
      create(:lab, labgroup: @labgroup)
    ])
  end

  it "renders a list of labs" do
    render
  end
end
