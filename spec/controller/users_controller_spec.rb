require "rails_helper"
require 'pry'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers
  describe "controller" do
    it "routes to #index" do
      expect(get: "/users").to route_to("users#index")
    end

    it "routes to #new" do
      expect(get: "/users/new").to route_to("users#new")
    end

    it "routes to #show" do
      expect(get: "/users/1").to route_to("users#show", id: "1")
    end

    it "routes to #create_staff" do
      expect(post: "/users/create_staff").to route_to("users#create_staff")
    end

    it "routes to #destroy" do
      expect(delete: "/users/1").to route_to("users#destroy", id: "1")
    end
  end

  describe("Signed in as patient") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:patient]) # in factories.rb you should create a factory for user
      @other_user = create(:user, role: User.roles[:patient])
      sign_in @user
    end

    it "should not let a patient see other users" do
      get :index
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient create a new user" do
      get :new
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should let a patient see their own profile " do
      get :show, params: { id: @user.id }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see someone else's profile " do
      get :show, params: { id: @other_user.id }
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient create a user via the staff routeroutes to #create_staff" do
      post :create_staff, params: { }
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should let a user delete themselves from the users controller" do
      delete :destroy, params: {id: @user.id}
      expect(flash[:notice]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a user delete another user from the users controller" do
      delete :destroy, params: {id: @other_user.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

  end

  describe("signed in as staff") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, :staff) # in factories.rb you should create a factory for user
      @other_user = create(:user, :patient)
      @to_create_user = build(:user, :patient)
      sign_in @user
    end

    it "should let a staff member see other users" do
      get :index
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member render the new user page" do
      get :new
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see their own profile " do
      get :show, params: { id: @user.id }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see someone else's profile " do
      get :show, params: { id: @other_user.id }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member create a patient via the staff routeroutes to #create_staff" do
      post :create_staff, params: {user: @to_create_user.attributes}
      expect(response).to have_http_status(:redirect)
      expect(User.last.email).to eq(@to_create_user.email)
    end

    it "should let a staff member create a staff member with no API key via the staff routeroutes to #create_staff" do
      post :create_staff, params: {user: @to_create_user.attributes.merge({role: 'staff'})}
      expect(response).to have_http_status(:redirect)
      expect(User.last.email).to eq(@to_create_user.email)
      expect(response).to redirect_to(user_path(User.last))
    end

    it "should let a user delete themselves from the users controller" do
      delete :destroy, params: {id: @user.id}
      expect(flash[:notice]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a user delete another user from the users controller" do
      # TODO should this redirect or even be a staff function??????
      delete :destroy, params: {id: @other_user.id}
      expect(flash[:alert]).to_not be_present
      expect(flash[:notice]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

  end
end
