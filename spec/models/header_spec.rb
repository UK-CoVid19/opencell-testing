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

    it "should not have duplicate keys for the same client" do
      @client = create(:client)

      @header = Header.create(key: 'bleep', value: 'bloop', client: @client)
      @header_dup = Header.new(key: 'bleep', value: 'blarp', client: @client)

      expect(@header_dup.save).to be false
      expect(@header_dup.errors[:key].size).to eq 1
    end

    it "should allow duplicate keys for a different client" do
      @client = create(:client)
      @client_dup = create(:client)

      @header = Header.create(key: 'bleep', value: 'bloop', client: @client)
      @header_dup = Header.new(key: 'bleep', value: 'blarp', client: @client_dup)

      expect(@header_dup.save).to be true
    end
  end
end
