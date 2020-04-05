require "rails_helper"

RSpec.describe HomeController, type: :controller do
  include Devise::Test::ControllerHelpers
  describe "controller without login" do
    it "routes to #index when no user logged in" do
      expect(get: "/").to route_to("home#index")
    end

    it "routes to #privacy" do
      expect(get: "/privacy").to route_to('home#privacy')
    end

    it "routes to #about" do
      expect(get: "/about").to route_to("home#about")
    end

  end

  describe 'logged in as patient' do

    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:patient]) # in factories.rb you should create a factory for user
      sign_in @user
    end

    it "routes to user profile path when user logged in" do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(user_path(@user))
    end

    it "routes to #privacy" do
      expect(get: "/privacy").to route_to('home#privacy')
    end

    it "routes to #about" do
      expect(get: "/about").to route_to("home#about")
    end
  end

  describe 'logged in as staff' do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
      sign_in @user
    end

    it "routes to #index when no user logged in" do
      get :index
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(staff_dashboard_path)
    end

    it "routes to #privacy" do
      expect(get: "/privacy").to route_to('home#privacy')
    end

    it "routes to #about" do
      expect(get: "/about").to route_to("home#about")
    end
  end
end
