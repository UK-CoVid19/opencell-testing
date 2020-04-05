require 'rails_helper'

RSpec.describe "samples/show", type: :view do
  before(:each) do
    @sample = assign(:sample, Sample.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
