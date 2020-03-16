require 'test_helper'

class SamplesControllerTest < ActionDispatch::IntegrationTest
  test "should get dispatch" do
    get samples_dispatch_url
    assert_response :success
  end

  test "should get receive" do
    get samples_receive_url
    assert_response :success
  end

  test "should get prepare" do
    get samples_prepare_url
    assert_response :success
  end

  test "should get process" do
    get samples_process_url
    assert_response :success
  end

  test "should get analyse" do
    get samples_analyse_url
    assert_response :success
  end

end
