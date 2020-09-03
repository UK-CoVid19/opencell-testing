require "rails_helper"

RSpec.describe ClientsController, type: :controller do
  include Devise::Test::ControllerHelpers
  describe "controller" do
    it "routes to #index" do
      expect(get: "/clients").to route_to("clients#index")
    end

    it "routes to #new" do
      expect(get: "/clients/new").to route_to("clients#new")
    end

    it "routes to #show" do
      expect(get: "/clients/1").to route_to("clients#show", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/clients/1").to route_to("clients#destroy", id: "1")
    end
  end

  describe("Signed in") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:patient]) # in factories.rb you should create a factory for user
      @other_user = create(:user, role: User.roles[:patient])
      sign_in @user
    end

    it "should view the index page" do
      get :index
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a user view the create client form" do
      get :new
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should show a client " do
      @client = create(:client)
      get :show, params: { id: @client.id }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should let a user delete themselves from the users controller" do
      @client = create(:client)
      delete :destroy, params: {id: @client.id}
      expect(flash[:notice]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(clients_path)
    end
   
  end

  describe("not signed in") do

    it "should be signed into see clients " do
      get :index
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "should be signed in to create client" do
      get :new
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "should be signed in to see client " do
      @client = create(:client)
      get :show, params: { id: @client.id }
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "should not allow deletion" do
      @client = create(:client)
      delete :destroy, params: {id: @client.id}
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
