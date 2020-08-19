require 'rails_helper'

RSpec.describe User, type: :model do
  it "should create a user and set an API key for a patient upon successful creation" do
    @user = build(:user, :patient)
    expect(@user.save).to eq true
    expect(@user.api_key).to_not be_nil
  end

  it "should not create an API key if the user is a staff member" do
    @user = build(:user, :staff)
    expect(@user.save).to eq true
    expect(@user.api_key).to be_nil
  end

  it "should create a hashed value of the provided API key" do
    @user = build(:user, :patient, api_key: 'abc')
    expect(@user.save).to eq true
    expect(@user.api_key).to_not be_nil
    expect(@user.api_key).to eq "ungWv48Bz+pBQUDeXa4iI7ADYaOWF3qctBD/YfIAFa0="
  end
end