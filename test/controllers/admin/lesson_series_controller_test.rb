require "test_helper"

class Admin::LessonSeriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_lesson_series_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_lesson_series_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_lesson_series_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_lesson_series_create_url
    assert_response :success
  end

  test "should get edit" do
    get admin_lesson_series_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_lesson_series_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_lesson_series_destroy_url
    assert_response :success
  end
end
