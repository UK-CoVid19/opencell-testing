require 'rails_helper'

RSpec.describe Client, type: :model do
  it "should not allow a duplicate name" do
    @client_a = create(:client, name: "myname")
    @client_b = build(:client, name: "myname")

    expect(@client_b.save).to eq false
    expect(@client_b.errors).to_not be nil
    expect(@client_b.errors[:name].first).to eq "has already been taken"
  end

  it "should allow a different names" do
    @client_a = create(:client, name: "myname")
    @client_b = build(:client, name: "myname2")

    expect(@client_b.save).to eq true
    expect(@client_b.errors.size).to eq 0
  end

  it "should require api key" do
    @client_a = Client.new(name: 'blah', notify: false)
    expect { @client_a.save }.to raise_error "API key required"
  end

  it "should create a valid record" do
    @client_a = Client.new(name: 'blah', api_key: 'abc', notify: false)
    expect(@client_a.save).to eq true
  end

  it "should create only 1 instance of the control client" do
    control = Client.control_client
    control_2 = Client.control_client
    expect(control).to eq control_2
  end
end
