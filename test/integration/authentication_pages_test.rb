require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  test "signin page elements" do
    get signin_path

    assert_select 'h1', 'Sign in'
    assert_select 'title', full_title('Sign in')
    assert_select 'a', text: 'Profile', count: 0
    assert_select 'a', text: 'Settings', count: 0
  end

  test "signin with invalid information" do
    get signin_path

    post_via_redirect sessions_path, { email: "", password: "" }

    assert_select 'title', full_title('Sign in')
    assert_error_message /Invalid/

    get root_path
    assert_select 'div.alert.alert-error', false
  end

  test "signin with valid information and signout" do
    user = users(:one)
    user.password = "foobar"
    sign_in user

    assert_select 'title', full_title(user.name)
    assert_select 'a[href=?]', users_path, 'Users'
    assert_select 'a[href=?]', user_path(user), 'Profile'
    assert_select 'a[href=?]', edit_user_path(user), 'Settings'
    assert_select 'a[href=?]', signout_path, 'Sign out'
    assert_select 'a[href=?]', signin_path, text: 'Sign in', count: 0

    delete signout_path
    assert_redirected_to root_path
    follow_redirect!
    assert_select 'a[href=?]', signin_path, 'Sign in'
  end

  test "authorization for non-signed-in users attempting to visit a protected page" do
    user = users(:one)
    user.password = "foobar"

    get_via_redirect edit_user_path(user)
    assert_select 'title', full_title('Sign in')
    sign_in user

    assert_select 'title', full_title('Edit user')

    delete signout_path
    sign_in user

    assert_select 'title', full_title(user.name)
  end

  test "authorization for non-signed-in users in the Users controller" do
    user = users(:one)
    get_via_redirect edit_user_path(user)
    assert_select 'title', full_title('Sign in')

    patch user_path(user)
    assert_redirected_to signin_path

    get_via_redirect users_path
    assert_select 'title', full_title('Sign in')

    get_via_redirect following_user_path(user)
    assert_select 'title', full_title('Sign in')

    get_via_redirect followers_user_path(user)
    assert_select 'title', full_title('Sign in')
  end

  test "authorization for non-signed-in users in the Microposts controller" do
    post microposts_path
    assert_redirected_to signin_path

    delete micropost_path(microposts(:first))
    assert_redirected_to signin_path
  end

  test "authorization for non-signed-in users in the Relationships controller" do
    post relationships_path
    assert_redirected_to signin_path

    delete relationship_path(1)
    assert_redirected_to signin_path
  end

  test "authorization as wrong user submitting improper requests to the Users controller" do
    user = users(:one)
    wrong_user = users(:two)
    sign_in user

    get edit_user_path(wrong_user)
    assert_select 'title', text: full_title('Edit user'), count: 0
    assert_redirected_to signin_path

    patch user_path(wrong_user)
    assert_redirected_to signin_path
  end

  test "authorization as non-admin user submitting a DELETE request to the Users#destroy action" do
    user = users(:one)
    non_admin = users(:two)

    sign_in non_admin

    delete user_path(user)
    assert_redirected_to signin_path
  end

  test "authorization as admin user submitting a DELETE request to the Users#destroy action for the current user" do
    admin = users(:admin)

    sign_in admin

    delete user_path(admin)
    assert_redirected_to signin_path
  end
end
