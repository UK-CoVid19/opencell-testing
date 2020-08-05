require 'rails_helper'

RSpec.describe "users/new", type: :view do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
    Sample.with_user(@user) do
      @sample = build(:sample, user: @user)
    end
    sign_in @user
  end

  it "renders new user form" do
    render
    assert_select "form[action=?][method=?]", create_staff_path, "post" do
    end
  end
end
