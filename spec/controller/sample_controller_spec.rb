require "rails_helper"
require 'pry'

RSpec.describe SamplesController, type: :controller do
  describe "controller" do
    it "routes to #index" do
      expect(get: "/samples").to route_to("samples#index")
    end

    it "routes to #new" do
      expect(get: "/samples/new").to route_to("samples#new")
    end

    it "routes to #show" do
      expect(get: "/samples/1").to route_to("samples#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/samples/1/edit").to route_to("samples#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/samples").to route_to("samples#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/samples/1").to route_to("samples#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/samples/1").to route_to("samples#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/samples/1").to route_to("samples#destroy", id: "1")
    end
  end

  describe("signed in as patient") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:patient]) # in factories.rb you should create a factory for user
      @other_user = create(:user, role: User.roles[:patient])
      Sample.with_user(@user) do
        @sample = create(:sample, user: @user)
      end

      Sample.with_user(@other_user) do
        @other_sample = create(:sample, user: @other_user)
      end
      sign_in @user
    end

    it "should not let a patient see samples" do
      get :index
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step1_pendingdispatch" do
      get :step1_pendingdispatch
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step2_pendingreceive" do
      get :step2_pendingreceive
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step3_pendingprepare" do
      get :step3_pendingprepare
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step4_pendingreadytest" do
      get :step4_pendingreadytest
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step5_pendingtest" do
      get :step5_pendingtest
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see step6_pendinganalyze" do
      get :step6_pendinganalyze
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see show" do
      get :show, params: {id: @sample.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see new" do
      get :index
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see edit" do
      get :index
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step1_bulkdispatched" do
      post :step1_bulkdispatched
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step2_bulkreceived" do
      post :step2_bulkreceived
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step3_bulkprepared" do
      post :step3_bulkprepared
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step4_bulkreadytest" do
      post :step4_bulkreadytest
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step5_bulktested" do
      post :step5_bulktested
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient post to step6_bulkanalysed" do
      post :step6_bulkanalysed
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should let a patient create a sample for themselves" do
      post :create, params: {sample: {user_id: @user.id}}
      expect(flash[:alert]).to_not be_present
      expect(flash[:notice]).to be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(user_path(@user))
    end

    it "should not let a patient create a sample for someone else" do
      post :create, params: {sample: {user_id: @other_user.id}}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient update a sample " do
      patch :update, params: {id: @sample.id, sample: @sample.attributes}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient update a sample for someone else " do
      patch :update, params: {id: @other_sample.id, sample: @other_sample.attributes}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient destroy their sample " do
      delete :destroy, params: {id: @sample.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient destroy someone elses sample " do
      delete :destroy, params: {id: @other_sample.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end
  end

  describe("signed in as staff member") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
      @other_user = create(:user, role: User.roles[:patient])
      Sample.with_user(@user) do
        @sample = create(:sample, user: @user)
      end

      sign_in @user
    end

    it "should let a staff member see samples" do
      get :index
      samples = assigns(:samples)
      expect(samples.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step1_pendingdispatch" do
      get :step1_pendingdispatch
      samples = assigns(:samples)
      expect(samples.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step2_pendingreceive" do
      get :step2_pendingreceive
      samples = assigns(:samples)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step3_pendingprepare" do
      get :step3_pendingprepare
      samples = assigns(:samples)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step4_pendingreadytest" do
      get :step4_pendingreadytest
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step5_pendingtest" do
      get :step5_pendingtest
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should not let a patient see step6_pendinganalyze" do
      get :step6_pendinganalyze
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end
  end
end
