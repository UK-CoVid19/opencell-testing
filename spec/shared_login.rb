RSpec.shared_context "create sample login", shared_context: :metadata do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
      @client = create(:client) # in factories.rb you should create a factory for user
      Sample.with_user(@user) do
        @sample = create(:sample, client: @client)
      end
      session[:labgroup] = @client.labgroup.id
      session[:lab] = @client.labgroup.labs.first.id
      sign_in @user
    end
  end