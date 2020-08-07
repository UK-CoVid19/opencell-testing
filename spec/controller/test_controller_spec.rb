require "rails_helper"

RSpec.describe TestsController, type: :controller do
  include Devise::Test::ControllerHelpers


    describe('signed in actions for tests') do
        pending('figure out how to make these tests work') 
        before :each do
            @request.env["devise.mapping"] = Devise.mappings[:user]
            @user = create(:user, role: User.roles[:staff]) # in factories.rb you should create a factory for user
            sign_in @user
            wells = build_list(:well, 96)
            Sample.with_user(@user) do
                @sample = create(:sample)
            end
            wells.last.sample = @sample
            @plate = create(:plate, wells: wells )
        end

        it "should create a valid test with valid params" do
            pending('figure out how to make these tests work')
            first_file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/data/test1.csv")
            @test = Test.new
            post :create, params: {plate_id: @plate.id, test: {user_id: @user.id, result_files: [first_file, first_file], test_results_attributes: [{value: 4, well_id: @sample.well.id, id: "", test_id: ""}]}}
            expect(response).to have_http_status(:success) 
        end

        it "should not create a valid test with 1 file" do 
            pending('figure out how to make these tests work')
            first_file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/data/test1.csv")
            @test = Test.new
            post :create, params: {test: {user_id: @user.id, result_files: [first_file], test_results_attributes: [{value: 4, well_id: @sample.well.id}]}, plate_id: @plate.id}
            expect(response).to have_http_status(:unprocessable_entity) 
        end

        it "should not create a valid test with no value for the well" do 
            pending('figure out how to make these tests work')
            first_file = Rack::Test::UploadedFile.new("#{Rails.root}/spec/data/test1.csv")
            @test = Test.new
            post :create, params: {test: {user_id: @user.id, result_files: [first_file, first_file], test_results_attributes: [{ well_id: @sample.well.id}]}, plate_id: @plate.id}
            expect(response).to have_http_status(:unprocessable_entity) 
        end
    end
end