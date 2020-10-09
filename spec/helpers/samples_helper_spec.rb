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

  describe "get_focus_index" do
    it "gets the right index for a given plate A1" do
      well = build(:well, row: 'A', column: 1)
      expect(helper.get_focus_index(well)).to eq(1)
    end

    it "gets the right index for a given plate A1" do
      well = build(:well, row: 'D', column: 6)
      expect(helper.get_focus_index(well)).to eq(44)
    end

    it "gets the right index for a given plate H12" do
      well = build(:well, row: 'H', column: 12)
      expect(helper.get_focus_index(well)).to eq(96)
    end

    it "should throw if out of range for row" do
      well = build(:well, row: 'K', column: 12)
      expect { helper.get_focus_index(well)}.to raise_error("row out of range K")
    end

    it "should throw if out of range for column" do
      well = build(:well, row: 'C', column: 13)
      expect { helper.get_focus_index(well)}.to raise_error("column out of range 13")
    end
  end

  describe "retest_selected" do
    it "should return the id of the query sample if it exists" do
      Sample.with_user(create(:user)) do
        @sample = create(:sample)
      end
      expect(helper.retest_selected(@sample, [])).to eq @sample.id
    end

    it "should return the first sample in the list if no query and sample available" do
      Sample.with_user(create(:user)) do
        @sample = create(:sample)
      end
      expect(helper.retest_selected(nil,[@sample])).to eq @sample.id
    end

    it "should return nil if no sample and nil available" do
      expect(helper.retest_selected(nil, nil)).to eq nil
    end

    it "should return nil if no sample and none available" do
      expect(helper.retest_selected(nil,[])).to eq nil
    end
  end 
end
