require 'rails_helper'

RSpec.describe "samples/new", type: :view do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
    Sample.with_user(@user) do
      @sample = build(:sample, user: @user)
    end
    sign_in @user
  end

  it "renders new sample form" do
    render
    assert_select "form[action=?][method=?]", samples_path, "post" do
    end
  end
end
