require 'rails_helper'

RSpec.describe "homes/index", type: :view do
  before(:each) do
    assign(:homes, [
      Home.create!(),
      Home.create!()
    ])
  end

  it "renders a list of homes" do
    render
  end
end
