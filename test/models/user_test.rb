# == Schema Information
#
# Table name: users
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  password_digest :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", 
                     password: "foobar", password_confirmation: "foobar")
  end

  test "user should respond to its members" do
    assert_respond_to @user, :name
    assert_respond_to @user, :email
    assert_respond_to @user, :password_digest
    assert_respond_to @user, :password
    assert_respond_to @user, :password_confirmation
    assert_respond_to @user, :remember_token
    assert_respond_to @user, :authenticate
    assert_respond_to @user, :admin
    assert_respond_to @user, :microposts
    assert_respond_to @user, :feed
    assert_respond_to @user, :relationships
    assert_respond_to @user, :followed_users
    assert_respond_to @user, :reverse_relationships
    assert_respond_to @user, :followers
    assert_respond_to @user, :following?
    assert_respond_to @user, :follow!
    assert_respond_to @user, :unfollow!
  end

  test "user should be valid" do
    assert @user.valid?
    assert_not @user.admin?
  end

  test "with admin attribute set to 'true'" do
    @user.save!
    @user.toggle!(:admin)
    assert @user.admin?
  end

  test "when name is not present" do
    @user.name = " "
    assert @user.invalid?
  end

  test "when email is not present" do
    @user.email = " "
    assert @user.invalid?
  end

  test "when name is too long" do
    @user.name = "a" * 51
    assert @user.invalid?
  end

  test "when email format is invalid" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                   foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    addresses.each do |invalid_address|
      @user.email = invalid_address
      assert @user.invalid?, "invalid address: #{invalid_address}"
    end
  end

  test "when email format is valid" do
    addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "valid address: #{valid_address}"
    end
  end

  test "when email address is already taken" do
    user_with_same_email = @user.dup
    user_with_same_email.save
    assert @user.invalid?

    user_with_same_email.email = @user.email.upcase
    user_with_same_email.save
    assert @user.invalid?
  end

  test "email address with mixed case should be saved as all lower case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal @user.reload.email, mixed_case_email.downcase
  end

  test "when password is not present" do
    @user.password = " "
    @user.password_confirmation = " "
    assert @user.invalid?
  end

  test "when password doesn't match confirmation" do
    @user.password_confirmation = "mismatch"
    assert @user.invalid?
  end

  test "return value of authenticate method" do
    @user.save
    found_user = User.find_by(email: @user.email)

    assert_equal @user, found_user.authenticate(@user.password)

    user_for_invalid_password = found_user.authenticate("invalid")
    assert_not_equal @user, user_for_invalid_password
    assert_not user_for_invalid_password
  end

  test "with a password that's too short" do
    @user.password = @user.password_confirmation = "a" * 5
    assert @user.invalid?
  end

  test "remember token" do
    @user.save
    assert_not @user.remember_token.blank?
  end

  test "micropost associations" do
    @user.save
    older_micropost = @user.microposts.create!(content: "Lorem ipsum", created_at: 1.day.ago)
    newer_micropost = @user.microposts.create!(content: "Lorem ipsum", created_at: 1.hour.ago)

    assert_equal [newer_micropost, older_micropost], @user.microposts

    unfollowed_post = users(:one).microposts.build(content: "Lorem ipsum")
    followed_user = users(:two)
    @user.follow!(followed_user)
    3.times { followed_user.microposts.create!(content: "Lorem ipsum") }

    assert @user.feed.include?(newer_micropost)
    assert @user.feed.include?(older_micropost)
    assert_not @user.feed.include?(unfollowed_post)
    followed_user.microposts.each do |micropost|
      assert @user.feed.include?(micropost)
    end

    microposts = @user.microposts.to_a
    @user.destroy
    assert_not microposts.empty?
    microposts.each do |micropost|
      assert Micropost.where(id: micropost.id).empty?
    end
  end

  test "following" do
    other_user = users(:one)
    @user.save
    @user.follow!(other_user)

    assert @user.following?(other_user)
    assert @user.followed_users.include?(other_user)
    assert other_user.followers.include?(@user)

    @user.unfollow!(other_user)
    assert_not @user.following?(other_user)
    assert_not @user.followed_users.include?(other_user)
    assert_not other_user.followers.include?(@user)
  end
end
