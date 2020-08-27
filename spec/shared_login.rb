RSpec.shared_context "create sample login", shared_context: :metadata do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
      @client = create(:client) # in factories.rb you should create a factory for user
      Sample.with_user(@user) do
        @sample = build(:sample, client: @client)
      end
      sign_in @user
    end
  end