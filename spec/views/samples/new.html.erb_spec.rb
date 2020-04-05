require 'rails_helper'

RSpec.describe "samples/new", type: :view do
  before(:each) do
    assign(:sample, Sample.new())
  end

  it "renders new sample form" do
    render

    assert_select "form[action=?][method=?]", samples_path, "post" do
    end
  end
end
