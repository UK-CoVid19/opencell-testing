require 'rails_helper'

RSpec.describe "samples/index", type: :view do
  
  before(:each) do
    @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
    @client = create(:client)
    Sample.with_user(@user) do
      @sample = create(:sample, client: @client)
    end
    assign(:samples, [
      @sample
    ])
  end

  it "renders a list of samples" do
    render
  end
end
