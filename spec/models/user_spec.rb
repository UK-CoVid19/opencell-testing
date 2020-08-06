require 'rails_helper'

RSpec.describe User, type: :model do
  it "should create a user and set an API key upon successful creation" do
    @user = build(:user)
    expect(@user.save).to eq true
    expect(@user.api_key).to_not be_nil
    expect(@user.api_key.size).to eq 24
  end
end