require "test_helper"

class BookingRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get booking_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get booking_requests_create_url
    assert_response :success
  end

  test "should get show" do
    get booking_requests_show_url
    assert_response :success
  end

  test "should get index" do
    get booking_requests_index_url
    assert_response :success
  end
end
