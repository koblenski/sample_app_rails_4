require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full_title" do
    assert_match /foo/, full_title("foo")
    assert_match /^Ruby on Rails Tutorial Sample App/, full_title("foo")
    assert_no_match /\|/, full_title("")
  end
end
