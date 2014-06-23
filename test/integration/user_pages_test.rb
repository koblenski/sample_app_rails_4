require 'test_helper'

class UserPagesTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:one)
    @user.password = "foobar"
    sign_in @user
    get users_path
  end

  test "index" do
    assert_select 'title', full_title('All users')
    assert_select 'h1', 'All users'
  end
  
  test "pagination" do
    assert_select 'div.pagination'

    User.paginate(page: 1).each do |user|
      assert_select 'li', user.name
    end
  end

  test "delete links" do
    assert_select 'delete', false

    admin = users(:admin)
    admin.password = 'foobar'
    sign_in admin
    get users_path

    assert_select 'a[href=?]', user_path(User.first), 'delete' 
    assert_difference 'User.count', -1 do
      delete user_path(User.first)
    end
    assert_select 'a[href=?]', user_path(admin), text: 'delete', count: 0
  end

  test "profile page" do
    m1 = microposts(:first)
    m2 = microposts(:second)

    get user_path(@user)

    assert_select 'h1', @user.name
    assert_select 'title', full_title(@user.name)
    assert_select 'span', m1.content
    assert_select 'span', m2.content
    assert_select 'h3', /#{@user.microposts.count}/

    other_user = users(:two)

    get user_path(other_user)

    assert_select 'input[value=?]', 'Follow'
    assert_select 'input[value=?]', other_user.id
    assert_difference ['@user.followed_users.count', 'other_user.followers.count'] do
      post relationships_path, relationship: { followed_id: other_user.id }
    end

    assert_redirected_to user_path(other_user)
    follow_redirect!

    assert_select 'input[value=?]', 'Unfollow'
    assert_difference ['@user.followed_users.count', 'other_user.followers.count'], -1 do
      delete relationship_path(Relationship.find_by(followed_id: other_user.id))
    end

    assert_redirected_to user_path(other_user)
    follow_redirect!
    assert_select 'input[value=?]', 'Follow'
  end

  test "signup page" do
    get signup_path

    assert_select 'h1', 'Sign up'
    assert_select 'title', full_title('Sign up')

    assert_no_difference 'User.count' do
      post users_path, user: { name: "", email: "", password: "", password_confirmation: "" }
    end

    assert_select 'title', full_title('Sign up')
    assert_error_message /error/

    assert_difference 'User.count' do
      post users_path, user: { name: "Example User", 
                               email: "user@example.com", 
                               password: "foobar", 
                               password_confirmation: "foobar" }
    end

    user = User.find_by(email: 'user@example.com')
    assert_redirected_to user_path(user)
    follow_redirect!
    assert_select 'title', full_title(user.name)
    assert_success /Welcome/
    assert_select 'a[href=?]', signout_path, 'Sign out'
  end

  test "edit" do
    get edit_user_path(@user)

    assert_select 'h1', 'Update your profile'
    assert_select 'title', full_title('Edit user')
    assert_select 'a[href=?]', 'http://gravatar.com/email', 'change'

    patch user_path(@user), user: { name: "", email: "", password: "", password_confirmation: "" } 
    assert_error_message /error/

    new_name = "New Name"
    new_email = "new@example.com"
    patch user_path(@user), user: { name: new_name,
                                    email: new_email,
                                    password: @user.password,
                                    password_confirmation: @user.password }
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_select 'title', full_title(new_name)
    assert_success 'Profile updated'
    assert_select 'a[href=?]', signout_path, 'Sign out'
    assert_equal new_name, @user.reload.name
    assert_equal new_email, @user.reload.email

    patch user_path(@user), user: { admin: true, password: @user.password,
                                    password_confirmation: @user.password }
    assert_not @user.admin?
  end

  test "following/followers" do
    other_user = users(:two)
    @user.follow!(other_user)

    get following_user_path(@user)

    assert_select 'title', full_title('Following')
    assert_select 'h3', 'Following'
    assert_select 'a[href=?]', user_path(other_user), other_user.name

    other_user.password = "foobar"
    sign_in other_user
    get followers_user_path(other_user)

    assert_select 'title', full_title('Followers')
    assert_select 'h3', 'Followers'
    assert_select 'a[href=?]', user_path(@user), @user.name
  end
end
