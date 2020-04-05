require 'rails_helper'

RSpec.describe "plates/index", type: :view do
  before(:each) do
    assign(:plates, [
      Plate.create!(),
      Plate.create!()
    ])
  end

  it "renders a list of plates" do
    render
  end
end
