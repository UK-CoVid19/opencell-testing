require "rails_helper"
require "shared_login"

RSpec.describe SamplesController, type: :controller do
  describe "controller" do
    it "routes to #index" do
      expect(get: "/samples").to route_to("samples#index")
    end

    it "routes to #pending_plate" do
      expect(get: "/samples/pendingplate").to route_to("samples#pending_plate")
    end

    it "routes to #pending_prepare" do
      expect(get: "/samples/pendingprepare").to route_to("samples#step3_pendingprepare")
    end

    it "routes to #pending_readytest" do
      expect(get: "/samples/pendingreadytest").to route_to("samples#step4_pendingreadytest")
    end

    it "routes to #pending_test" do
      expect(get: "/samples/pendingtest").to route_to("samples#step5_pendingtest")
    end

    it "routes to #pending_analyze" do
      expect(get: "/samples/pendinganalyze").to route_to("samples#step6_pendinganalyze")
    end

    it "routes to samples#dashboard" do
      expect(get: "/samples/dashboard").to route_to("samples#dashboard")
    end

    it "routes to samples#prepared" do
      expect(post: "/samples/prepared").to route_to("samples#step3_bulkprepared")
    end

    it "routes to samples#readytest" do
      expect(post: "/samples/readytest").to route_to("samples#step4_bulkreadytest")
    end

    it "routes to samples#tested" do
      expect(post: "/samples/tested").to route_to("samples#step5_bulktested")
    end

    it "routes to samples#analysed" do
      expect(post: "/samples/analysed").to route_to("samples#step6_bulkanalysed")
    end

    it "routes to #new" do
      expect(get: "/samples/new").to route_to("samples#new")
    end

    it "routes to #show" do
      expect(get: "/samples/1").to route_to("samples#show", id: "1")
    end

    it "routes to #create" do
      expect(post: "/samples").to route_to("samples#create")
    end

    it "routes to #reject" do
      expect(patch: "/samples/1/reject").to route_to("samples#reject", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/samples/1").to route_to("samples#destroy", id: "1")
    end

    it "routes to #retestpositive" do
      expect(post: "/samples/1/retestpositive").to route_to("samples#retestpositive", id: "1")
    end

    it "routes to #retestinconclusive" do
      expect(post: "/samples/1/retestinconclusive").to route_to("samples#retestinconclusive", id: "1")
    end
  end

  context("signed in as patient") do
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @other_user = create(:user, role: User.roles[:patient])
      @client = create(:client)
      Sample.with_user(@other_user) do
        @sample = create(:sample, client: @client)
      end

      sign_in @other_user
    end

    it "should not let a patient see samples" do
      get :index
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient see samples pending plating" do
      get :pending_plate
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

    it "should not let a patient create a sample for themselves" do
      post :create, params: {sample: {client_id: @client.id}}
      expect(flash[:alert]).to be_present
      expect(flash[:notice]).to_not be_present
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end

    it "should not let a patient create a sample for someone else" do
      post :create, params: {sample: {client_id: @client.id}}
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
      delete :destroy, params: {id: @sample.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    end
      
    it "should not let a patient reject a sample " do
      patch :reject, params: {id: @sample.id}
      expect(flash[:alert]).to eq("You are not authorized to perform this action")
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(root_path)
    
    end
  end

  context("signed in as staff member") do
    include_context "create sample login"

    it "should let a staff member see samples" do
      get :index
      samples = assigns(:samples)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see pending plate samples" do
      Sample.with_user(@user) do
        create(:sample, state: Sample.states[:received])
      end
      get :pending_plate
      samples = assigns(:samples)
      expect(samples.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step3_pendingprepare" do
      get :step3_pendingprepare
      samples = assigns(:samples)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step4_pendingreadytest" do
      get :step4_pendingreadytest
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step5_pendingtest" do
      get :step5_pendingtest
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step6_pendinganalyze" do
      get :step6_pendinganalyze
      samples = assigns(:plates)
      expect(samples.size).to eq(0)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member create a sample with the correct defaults" do
      before = Sample.all.size
      post :create, params: {sample: {client_id: @client.id }}
      expect(flash[:alert]).to be_nil
      expect(response).to redirect_to client_path(@client)
      expect(Sample.all.size).to eq before + 1
      expect(Sample.last.state).to eq :received.to_s
    end

    it "should let a staff member reject a sample " do
      patch :reject, params: { id: @sample.id }
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(pending_plate_path)
      expect(Sample.find(@sample.id).state).to eq :rejected.to_s
    end

    describe "step3_bulkprepare" do
      # note that samples should not be in the permanent control wells
      before :each do
        @wells = build_list(:well, 96)
        @plate = build(:plate, wells: @wells)
      end
      it "should create a valid plate with valid samples" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        current_samples = Sample.all.size
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'C', column: 1, id: @this_sample.id, control: false}]}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/samples/pendingreadytest")
        expect(flash[:alert]).to_not be_present
        expect(Plate.all.size).to eq 1
        expect(Well.all.size).to eq 96
        expect(Sample.all.size).to eq current_samples
      end

      it "needs a permanent variable control well to have the checking value" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id, control: true, control_code: 1234}]}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/samples/pendingreadytest")
      end

      it "should fail without a correct control cell check value" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id, control: true, control_code: nil}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
      end

      it "should fail with a sample assigned to a well twice" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'C', column: 1, id: @this_sample.id, control: false}, {row:'C', column: 1, id: @this_other_sample.id, control: false}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
      end

      it "should fail with a sample assigned to a well twice" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id}, {row:'A', column: 2, id: @this_sample.id}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
      end

      it "should fail with a sample assigned to a well which has the wrong status" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
      end

      it "should fail with a sample assigned to a well which cannot be found" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 99, id: @this_sample.id}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
      end

      it "should not create new samples if the transcation fails" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        current_samples = Sample.all.size
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 99, id: @this_sample.id}, {row:'A', column: 1, id: nil, control: true, control_code: Sample::CONTROL_CODE}]}}
        expect(response).to render_template(:step3_pendingprepare)
        expect(flash[:alert]).to be_present
        expect(Plate.all.size).to eq 0
        expect(Well.all.size).to eq 0
        expect(Sample.all.size).to eq current_samples
      end

      it "should create new samples if the transcation succeeds for the controls" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        current_samples = Sample.all.size
        post :step3_bulkprepared, params: { plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 6, id: @this_sample.id}, {row:'A', column: 1, id: nil, control: true, control_code: Sample::CONTROL_CODE}]}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/samples/pendingreadytest")
        expect(Sample.all.size).to eq current_samples + 1
      end
    end

    describe "set reruns" do
      it "should create a incon. rerun for a sample if it does not have a rerun already" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:tested], client: @client)
        end
        post :retestinconclusive, params: {id: @this_sample.id }
        expect(response).to have_http_status(:redirect)
        s = Sample.find(@this_sample.id)
        expect(s.state).to eq "retest"
        expect(s.rerun.present?).to eq true
        expect(s.rerun.reason).to eq Rerun::INCONCLUSIVE
        expect(s.retest.uid).to eq @this_sample.uid
      end

      it "should create a positive rerun for a sample if it does not have a rerun already" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:tested], client: @client)
        end
        post :retestpositive, params: {id: @this_sample.id }
        expect(response).to have_http_status(:redirect)
        s = Sample.find(@this_sample.id)
        expect(s.state).to eq "retest"
        expect(s.rerun.present?).to eq true
        expect(s.rerun.reason).to eq Rerun::POSITIVE
        expect(s.retest.uid).to eq @this_sample.uid
      end

      it "should not create a rerun and fail if trying to create a rerun where one already exists" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:tested], client: @client)
          @this_sample.create_retest(Rerun::INCONCLUSIVE)
        end
        post :retestinconclusive, params: {id: @this_sample.id }
        expect(response).to have_http_status(:bad_request)
      end

      it "should not create a rerun and fail if trying to create a rerun where one already exists" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:tested], client: @client)
          @this_sample.create_retest(Rerun::POSITIVE)
        end
        post :retestpositive, params: {id: @this_sample.id }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
