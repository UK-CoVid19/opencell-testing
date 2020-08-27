require 'rails_helper'

RSpec.describe "clients/index", type: :view do
  before(:each) do
    assign(:clients, [
      Client.create!(
        name: "Name",
        api_key_hash: "Api Key Hash"
      ),
      Client.create!(
        name: "Name",
        api_key_hash: "Api Key Hash"
      )
    ])
  end

  it "renders a list of clients" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "Api Key Hash".to_s, count: 2
  end
end
