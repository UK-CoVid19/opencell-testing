require 'rails_helper'

RSpec.describe "samples/index", type: :view do
  before(:each) do
    assign(:samples, [
      Sample.create!(),
      Sample.create!()
    ])
  end

  it "renders a list of samples" do
    render
  end
end
