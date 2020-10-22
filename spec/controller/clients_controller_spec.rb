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

    it "routes to #edit" do
      expect(get: "/clients/1/edit").to route_to("clients#edit", id: "1")
    end

    it "routes to #update with put" do
      expect(put: "/clients/1").to route_to("clients#update", id: "1")
    end

    it "routes to #update with patch" do
      expect(patch: "/clients/1").to route_to("clients#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/clients/1").to_not be_routable
    end

    it "routes to #stats" do
      expect(get: "/clients/1/stats").to route_to("clients#stats", id: "1")
    end

    it "routes to #testhook" do
      expect(post: "/clients/1/testhook").to route_to("clients#testhook", id: "1")
    end

    it "routes to #samples" do
      expect(get: "/clients/1/samples").to route_to("clients#samples", id: "1")
    end
  end

  describe("Signed in") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
      sign_in @user
    end

    it "should view the index page" do
      get :index
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should view the stats page as html" do
      @client = create(:client)
      get :stats, params: { id: @client.id }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should view the stats page as json" do
      @client = create(:client)
      get :stats, params: { id: @client.id }, format: :json
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
    end

    it "should view the clients samples in json format" do
      @client = create(:client)
      @other_client = create(:client)
      Sample.with_user(create(:user)) do
        @sample = create(:sample, client: @client)
        @sample_2 = create(:sample, client: @other_client)
      end
      get :samples, params: { id: @client.id }
      expect(response).to have_http_status(:success)
      expect(response.body).to match "\"uid\":\"#{@sample.uid}\""
      expect(response.body).to_not match "\"uid\":\"#{@sample_2.uid}\""
    end 

    it "should view the stats page as csv" do
      @client = create(:client)
      get :stats, params: { id: @client.id }, format: :csv
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

    it "should create a client" do
      @client = build(:client, notify: true, name: "test name")
      post :create, params: { client: @client.attributes }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
      expect(Client.last.notify).to eq true
      expect(Client.last.name).to eq "test name"
    end

    it "should create a client with webhook parameters" do

      notify_attributes = {headers_attributes: [{key: "Authorization", value: "Basic asd9h802ij"}]}
      @client = build(:client, notify: true, name: "test name", url: 'https://abc.com/endpoint')
      post :create, params: { client: @client.attributes.merge!(notify_attributes) }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
      expect(Client.last.notify).to eq true
      expect(Client.last.name).to eq "test name"
      expect(Client.last.url).to eq 'https://abc.com/endpoint'
      expect(Client.last.headers.size).to eq 1
      expect(Client.last.headers.first.key).to eq "Authorization"
      expect(Client.last.headers.first.value).to eq "Basic asd9h802ij"
    end

    it "should create a client with multiple parameters" do
      notify_attributes = {headers_attributes: [{key: "Authorization", value: "Basic asd9h802ij"},{key: "apikey", value: "blah"}]}
      @client = build(:client, notify: true, name: "test name", url: 'https://abc.com/endpoint')
      attrs = @client.attributes.merge!(notify_attributes)
      post :create, params: { client: attrs }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:success)
      expect(Client.last.notify).to eq true
      expect(Client.last.name).to eq "test name"
      expect(Client.last.url).to eq 'https://abc.com/endpoint'
      expect(Client.last.headers.size).to eq 2
      expect(Client.last.headers.first.key).to eq "Authorization"
      expect(Client.last.headers.first.value).to eq "Basic asd9h802ij"
      expect(Client.last.headers.second.key).to eq "apikey"
      expect(Client.last.headers.second.value).to eq "blah"
    end

    it "should update a client and its headers" do

      @client = create(:client, notify: true, name: "test name", url: "https://blah.com")
      notify_attributes = {url: 'https://abc.com/endpoint', notify: false, headers_attributes: [{ id: @client.headers.first.id, key: "Authorization", value: "Basic asd9h802ij"},{id: @client.headers.last.id, key: "apikey", value: "blah"}]}
      put :update, params: { id: @client.id, client: notify_attributes }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:redirect)
      @updated_client = Client.find(@client.id)
      expect(@updated_client.notify).to eq false
      expect(@updated_client.name).to eq "test name"
      expect(@updated_client.url).to eq 'https://abc.com/endpoint'
      expect(@updated_client.headers.size).to eq 2
      expect(@updated_client.headers.first.key).to eq "Authorization"
      expect(@updated_client.headers.first.value).to eq "Basic asd9h802ij"
      expect(@updated_client.headers.second.key).to eq "apikey"
      expect(@updated_client.headers.second.value).to eq "blah"
    end

    it "should update a client to create a new header if it does not already exist" do
      @client = create(:client, notify: true, name: "test name", url: "https://blah.com")
      notify_attributes = {url: 'https://abc.com/endpoint', notify: false, headers_attributes: [{ id: @client.headers.first.id, key: "Authorization", value: "Basic asd9h802ij"},{id: nil, key: "apikey", value: "blah"}]}
      put :update, params: { id: @client.id, client: notify_attributes }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:redirect)
      @updated_client = Client.find(@client.id)
      expect(@updated_client.notify).to eq false
      expect(@updated_client.name).to eq "test name"
      expect(@updated_client.url).to eq 'https://abc.com/endpoint'
      expect(@updated_client.headers.size).to eq 3
      expect(@updated_client.headers.first.key).to eq "Authorization"
      expect(@updated_client.headers.first.value).to eq "Basic asd9h802ij"
      expect(@updated_client.headers.last.key).to eq "apikey"
      expect(@updated_client.headers.last.value).to eq "blah"
    end

    it "should update a client to delete headers" do
      @client = create(:client, notify: true, name: "test name", url: "https://blah.com")
      notify_attributes = {url: 'https://abc.com/endpoint', notify: false, headers_attributes: [{ id: @client.headers.first.id, _destroy: true}]}
      expect(@client.headers.size).to eq 2
      put :update, params: { id: @client.id, client: notify_attributes }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:redirect)
      @updated_client = Client.find(@client.id)
      expect(@updated_client.notify).to eq false
      expect(@updated_client.name).to eq "test name"
      expect(@updated_client.url).to eq 'https://abc.com/endpoint'
      expect(@updated_client.headers.size).to eq 1
    end

    it "should update a client" do
      @client = create(:client, notify: true, name: "test name")
      put :update, params: { id: @client.id, client: { id: @client.id, name: "edited name" } }
      expect(flash[:alert]).to_not be_present
      expect(response).to have_http_status(:redirect)
      expect(Client.last.notify).to eq true
      expect(Client.last.name).to eq "edited name"
      expect(response).to redirect_to(client_path(@client))
    end

  end

  describe("not signed in") do
    it "should be signed into see clients " do
      get :index
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "should be signed into see stats " do
      @client = create(:client)
      get :stats, params: { id: @client.id }
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

    it "should be signed in create a client" do
      @client = build(:client, notify: true, name: "test name")
      post :create, params: { client: @client.attributes }
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "should be signed in to update a client" do 
      @client = create(:client, notify: true, name: "test name")
      put :update, params: { id: @client.id, client: { id: @client.id, name: "edited name" } }
      expect(flash[:alert]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
