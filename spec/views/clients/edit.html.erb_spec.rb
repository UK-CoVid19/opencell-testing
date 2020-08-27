require 'rails_helper'

RSpec.describe "clients/edit", type: :view do
  before(:each) do
    @client = assign(:client, Client.create!(
      name: "MyString",
      api_key_hash: "MyString"
    ))
  end

  it "renders the edit client form" do
    render

    assert_select "form[action=?][method=?]", client_path(@client), "post" do

      assert_select "input[name=?]", "client[name]"

      assert_select "input[name=?]", "client[api_key_hash]"
    end
  end
end
