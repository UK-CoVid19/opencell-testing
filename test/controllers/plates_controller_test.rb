require 'test_helper'

class PlatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @plate = plates(:one)
  end

  test "should get index" do
    get plates_url
    assert_response :success
  end

  test "should get new" do
    get new_plate_url
    assert_response :success
  end

  test "should show plate" do
    get plate_url(@plate)
    assert_response :success
  end

  test "should get edit" do
    get edit_plate_url(@plate)
    assert_response :success
  end

  test "should update plate" do
    wells = 96.times.map {|a| Well.new()}.map {|w| {id: w.id}}
    patch plate_url(@plate), params: { plate: { wells: [] } }
    assert_redirected_to plate_url(@plate)
  end

  test "should destroy plate" do
    assert_difference('Plate.count', -1) do
      delete plate_url(@plate)
    end

    assert_redirected_to plates_url
  end
end
