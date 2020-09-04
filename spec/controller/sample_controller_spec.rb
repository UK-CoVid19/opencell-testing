require "rails_helper"
require "shared_login"

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

    it "routes to #create" do
      expect(post: "/samples").to route_to("samples#create")
    end

    it "routes to #destroy" do
      expect(delete: "/samples/1").to route_to("samples#destroy", id: "1")
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
  end

  context("signed in as staff member") do
    
    include_context "create sample login"

    it "should let a staff member see samples" do
      get :index
      samples = assigns(:samples)
      expect(samples.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step1_pendingdispatch" do
      get :step1_pendingdispatch
      samples = assigns(:samples)
      expect(samples.size).to eq(1)
      expect(flash[:alert]).to be_nil
      expect(response).to have_http_status(:success)
    end

    it "should let a staff member see step2_pendingreceive" do
      get :step2_pendingreceive
      samples = assigns(:samples)
      expect(samples.size).to eq(0)
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

    describe("step1_bulkdispatched") do
      it "should accept a valid input for bulk updating samples in step1_bulkdispatched" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:requested], client: @client)
        end
        post :step1_bulkdispatched, params: {samples: [{id: @this_sample.id, note: "this is a note"}]}
        expect(Sample.all.size).to eq 2
        expect(Sample.last).to eq @this_sample
        expect(Sample.states.to_hash[Sample.last.state]).to eq Sample.states[:dispatched]
      end

      it "should accept a valid input for bulk updating 2 samples in step1_bulkdispatched" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:requested], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:requested], client: @client)
        end
        post :step1_bulkdispatched, params: { samples: [{id: @this_sample.id, note: "this is a note"}, {id: @this_other_sample.id, note: "blah"}]}
        expect(Sample.all.size).to eq 3
        expect(Sample.second).to eq @this_sample
        expect(Sample.third).to eq @this_other_sample
        expect(Sample.states.to_hash[Sample.second.state]).to eq Sample.states[:dispatched]
        expect(Sample.states.to_hash[Sample.third.state]).to eq Sample.states[:dispatched]
      end

      it "if 1 valid sample and 1 invalid sample, none of them update step1_bulkdispatched" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:requested], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:prepared], client: @client)
        end
        post :step1_bulkdispatched, params: {samples: [{id: @this_sample.id, note: "this is a note"}, {id: @this_other_sample.id, note: "blah"}]}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Sample.all.size).to eq 3
        expect(Sample.second).to eq @this_sample
        expect(Sample.third).to eq @this_other_sample
        expect(Sample.states.to_hash[Sample.second.state]).to eq Sample.states[:requested]
        expect(Sample.states.to_hash[Sample.third.state]).to eq Sample.states[:prepared]
      end
    end

    describe("step2_bulkreceived") do
      it "should accept a valid input for bulk receiving samples" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        post :step2_bulkreceived, params: {samples: [{id: @this_sample.id, note: "this is a note"}]}
        expect(Sample.all.size).to eq 2
        expect(Sample.last).to eq @this_sample
        expect(Sample.states.to_hash[Sample.last.state]).to eq Sample.states[:received]
      end

      it "should accept a valid input for bulk updating 2 samples in step2_bulkreceived" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        post :step2_bulkreceived, params: {samples: [{id: @this_sample.id, note: "this is a note"}, {id: @this_other_sample.id, note: "blah"}]}
        expect(Sample.all.size).to eq 3
        expect(Sample.second).to eq @this_sample
        expect(Sample.third).to eq @this_other_sample
        expect(Sample.states.to_hash[Sample.second.state]).to eq Sample.states[:received]
        expect(Sample.states.to_hash[Sample.third.state]).to eq Sample.states[:received]
      end

      it "if 1 valid sample and 1 invalid sample, none of them update step2_bulkreceived" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:requested], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        post :step2_bulkreceived, params: {samples: [{id: @this_sample.id, note: "this is a note"}, {id: @this_other_sample.id, note: "blah"}]}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Sample.all.size).to eq 3
        expect(Sample.second).to eq @this_sample
        expect(Sample.third).to eq @this_other_sample
        expect(Sample.states.to_hash[Sample.second.state]).to eq Sample.states[:requested]
        expect(Sample.states.to_hash[Sample.third.state]).to eq Sample.states[:dispatched]
      end

      it "it cannot have an invalid backwards state transition" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:prepared], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        post :step2_bulkreceived, params: {samples: [{id: @this_sample.id, note: "this is a note"}, {id: @this_other_sample.id, note: "blah"}]}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Sample.all.size).to eq 3
        expect(Sample.second).to eq @this_sample
        expect(Sample.third).to eq @this_other_sample
        expect(Sample.states.to_hash[Sample.second.state]).to eq Sample.states[:prepared]
        expect(Sample.states.to_hash[Sample.third.state]).to eq Sample.states[:dispatched]
      end
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
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'C', column: 1, id: @this_sample.id, control: false}]}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/samples/pendingreadytest")
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
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should fail with a sample assigned to a well twice" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'C', column: 1, id: @this_sample.id, control: false}, {row:'C', column: 1, id: @this_other_sample.id, control: false}]}}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should fail with a sample assigned to a well twice" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
          @this_other_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id}, {row:'A', column: 2, id: @this_sample.id}]}}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should fail with a sample assigned to a well which has the wrong status" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:dispatched], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 1, id: @this_sample.id}]}}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should fail with a sample assigned to a well which cannot be found" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 99, id: @this_sample.id}]}}
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should not create new samples if the transcation fails" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        current_samples = Sample.all.size
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 99, id: @this_sample.id}, {row:'A', column: 1, id: nil, control: true, control_code: Sample::CONTROL_CODE}]}}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Sample.all.size).to eq current_samples
      end

      it "should create new samples if the transcation succeeds for the controls" do
        Sample.with_user(@user) do
          @this_sample = create(:sample, state: Sample.states[:received], client: @client)
        end
        plate_attributes = @plate.attributes
        plate_attributes["wells_attributes"] = @wells.map(&:attributes).map {|a| a.except("id", "plate_id", "created_at", "updated_at", "sample_id")}
        current_samples = Sample.all.size
        post :step3_bulkprepared, params: {plate: plate_attributes, sample_well_mapping: {mappings: [{row:'A', column: 6, id: @this_sample.id}, {row:'A', column: 1, id: nil, control: true, control_code: Sample::CONTROL_CODE}]}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/samples/pendingreadytest")
        expect(Sample.all.size).to eq current_samples + 1
      end
    end
  end
end
