require 'rails_helper'

RSpec.describe "labs/show", type: :view do
  before(:each) do
    @lab = assign(:lab, Lab.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
