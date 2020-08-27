require 'rails_helper'
require "shared_login"

RSpec.describe "samples/new", type: :view do
  include_context "create sample login"

  it "renders new sample form" do
    render
    assert_select "form[action=?][method=?]", samples_path, "post" do
    end
  end
end
