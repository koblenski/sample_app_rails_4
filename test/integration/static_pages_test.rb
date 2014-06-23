require 'test_helper'

class StaticPagesTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def assert_static_page(heading, page_title = nil)
    assert_select 'h1', heading
    assert_select 'title', full_title(page_title || heading)
  end

  test "Home page for signed-in users" do
    get root_path
    assert_static_page 'Welcome to the Sample App', ''
    assert_select 'title', text: full_title('Home'), count: 0
    assert_select 'a[href=?]', about_path,    'About'
    assert_select 'a[href=?]', help_path,     'Help'
    assert_select 'a[href=?]', contact_path,  'Contact'
    assert_select 'a[href=?]', root_path,     'Home'
    assert_select 'a[href=?]', signup_path,   'Sign up now!'
    assert_select 'a[href=?]', root_path,     'sample app'

    user = users(:one)
    user.password = 'foobar'
    sign_in user
    post microposts_path, micropost: { content: "Lorem ipsum" }
    post microposts_path, micropost: { content: "Dolor sit amet" }
    get root_path

    user.feed.each do |item|
      assert_select "li##{item.id}", /#{item.content}/
    end

    other_user = users(:two)
    other_user.follow!(user)
    get root_path

    assert_select 'a[href=?]', following_user_path(user), /0\s+following/
    assert_select 'a[href=?]', followers_user_path(user), /1\s+followers/
  end

  test "Help page" do
    get help_path
    assert_static_page 'Help'
  end

  test "Contact page" do
    get contact_path
    assert_static_page 'Contact'
  end

  test "About page" do
    get about_path
    assert_static_page 'About Us'
  end
end
