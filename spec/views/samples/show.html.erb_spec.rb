require 'rails_helper'

RSpec.describe "samples/show", type: :view do
  before(:each) do
    @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
    Sample.with_user(@user) do
      @sample = create(:sample, user: @user)
    end
  end

  it "renders attributes in <p>" do
    render
  end
end
