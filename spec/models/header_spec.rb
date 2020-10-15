require 'rails_helper'

RSpec.describe Header, type: :model do
  describe "validations" do
    it "should require a key and value" do
      @client = create(:client)

      @header = Header.new(key: 'bleep', value: 'bloop', client: @client)

      expect(@header.save).to be true
    end

    it "should not save without a key and value" do
      @client = create(:client)

      @header = Header.new(key: 'bleep', value: nil, client: @client)

      expect(@header.save).to be false
    end

    it "should not save without a key and value 2" do
      @client = create(:client)

      @header = Header.new(key: nil, value: nil, client: @client)

      expect(@header.save).to be false
    end

    it "should not save without a key and value 3" do
      @client = create(:client)

      @header = Header.new(key: nil, value: 'bleep', client: @client)

      expect(@header.save).to be false
    end

    it "should not save without a client" do
      @client = create(:client)

      @header = Header.new(key: 'bleep', value: 'bloop', client: nil)

      expect(@header.save).to be false
    end
  end
end
