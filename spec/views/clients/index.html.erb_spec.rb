require 'rails_helper'

RSpec.describe "clients/index", type: :view do
  before(:each) do
    assign(:clients, [
      Client.create!(
        name: "Name",
        api_key: "Api Key Hash"
      ),
      Client.create!(
        name: "Name2",
        api_key: "Api Key Hash"
      )
    ])
  end

  it "renders a list of clients" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 1
    assert_select "tr>td", text: "Name2".to_s, count: 1
  end
end
