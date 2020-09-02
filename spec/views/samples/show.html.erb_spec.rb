require 'rails_helper'
require "shared_login"
RSpec.describe "samples/show", type: :view do
  include_context "create sample login"

  it "renders attributes in <p>" do
    render
  end
end
