require 'rails_helper'

RSpec.describe ClientsHelper, type: :helper do
  describe "get headers" do
    it "should return an empty header if the client has none" do
      @client = create(:client, headers: [])
      headers = get_headers(@client)
      expect(headers.size).to eq 1
      expect(headers[0].key).to eq nil
      expect(headers[0].value).to eq nil
      expect(headers[0].persisted?).to eq false
    end

    it "should return valid headers" do
      @client = create(:client, headers: [Header.create(key: "blah", value: "bloop")])
      headers = get_headers(@client)
      expect(headers.size).to eq 1
      expect(headers[0].key).to eq "blah"
      expect(headers[0].value).to eq "bloop"
      expect(headers[0].persisted?).to eq true
    end
  end
end
