require 'rails_helper'
require "shared_login"
RSpec.describe "samples/new", type: :view do
  before :each do 
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, role: User.roles[:staff])
    @sample = Sample.new
    sign_in @user
  end

  it "renders new sample form" do
    render
    assert_select "form[action=?][method=?]", samples_path, "post" do
      assert_select "select[name=?]", "sample[client_id]"
    end
  end
end
