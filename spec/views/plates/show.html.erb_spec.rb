require 'rails_helper'

RSpec.describe "plates/show", type: :view do
  before(:each) do
    @plate = assign(:plate, Plate.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
