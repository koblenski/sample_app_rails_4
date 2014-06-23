require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  test "user attributes must not be empty" do
    micropost = Micropost.new
    assert micropost.invalid?
    assert micropost.errors[:content].any?
  end

  def setup
    @user = users(:one)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "micropost should respond to its members" do
    assert_respond_to @micropost, :content
    assert_respond_to @micropost, :user_id
    assert_respond_to @micropost, :user
    assert_equal @micropost.user, @user

    assert @micropost.valid?
  end

  test "when user_id is not present" do
    @micropost.user_id = nil
    assert @micropost.invalid?
  end
  
  test "with blank content" do
    @micropost.content = " "
    assert @micropost.invalid?
  end

  test "with content that is too long" do
    @micropost.content = "a" * 141
    assert @micropost.invalid?
  end
end
