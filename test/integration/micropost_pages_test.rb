require 'test_helper'

class MicropostPagesTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @user.password = "foobar"
    sign_in @user
  end

  test "micropost creation with invalid information" do
    get root_path

    assert_no_difference( 'Micropost.count' ) do
      post microposts_path, micropost: { content: "" }
    end

    assert_error_message /error/
  end

  test "micropost with valid information" do
    get root_path

    assert_difference( 'Micropost.count' ) do
      post microposts_path, micropost: { content: "Lorem ipsum" }
    end

    assert_match /Micropost created/, flash[:success]
    assert_redirected_to root_path
  end

  test "micropost destruction" do
    post microposts_path, micropost: { content: "Lorem ipsum" }

    assert_difference( 'Micropost.count', -1 ) do
      delete micropost_path(assigns(:micropost).id)
    end
  end
end
