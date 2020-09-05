require 'rails_helper'

RSpec.describe SamplesHelper, type: :helper do
  describe "get_control_badge" do
    it "builds a control tag " do
      expect(helper.get_control_badge(true)).to eq('<span class="badge badge-pill badge-warning">Control</span>')
    end
    it "builds a sample tag " do
      expect(helper.get_control_badge(false)).to eq('<span class="badge badge-pill badge-primary">Sample</span>')
    end
    it "handles nil " do
      expect(helper.get_control_badge(nil)).to eq('<span class="badge badge-pill badge-primary">Sample</span>')
    end
  end
end
