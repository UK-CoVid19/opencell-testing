require "rails_helper"

RSpec.describe LabsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/labs").to route_to("labs#index")
    end

    it "routes to #new" do
      expect(get: "/labs/new").to route_to("labs#new")
    end

    it "routes to #show" do
      expect(get: "/labs/1").to route_to("labs#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/labs/1/edit").to route_to("labs#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/labs").to route_to("labs#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/labs/1").to route_to("labs#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/labs/1").to route_to("labs#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/labs/1").to route_to("labs#destroy", id: "1")
    end
  end
end
