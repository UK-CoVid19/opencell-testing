require 'rails_helper'

RSpec.describe "labs/index", type: :view do
  before(:each) do
    assign(:labs, [
      Lab.create!(),
      Lab.create!()
    ])
  end

  it "renders a list of labs" do
    render
  end
end
