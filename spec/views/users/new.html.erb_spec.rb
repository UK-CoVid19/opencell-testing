require 'rails_helper'
require "shared_login"

RSpec.describe "users/new", type: :view do
  include_context "create sample login"

  it "renders new user form" do
    render
    assert_select "form[action=?][method=?]", create_staff_path, "post" do
    end
  end
end
