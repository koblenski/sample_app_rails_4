require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @follower = users(:one)
    @followed = users(:two)
    @relationship = @follower.relationships.build(followed_id: @followed.id)
  end

  test "relationship should be valid" do
    assert @relationship.valid?
  end

  test "follower methods" do
    assert_respond_to @relationship, :follower
    assert_respond_to @relationship, :followed
    assert_equal @relationship.follower, @follower
    assert_equal @relationship.followed, @followed
  end

  test "when followed id is not present" do
    @relationship.followed_id = nil
    assert @relationship.invalid?
  end

  test "when follower id is not present" do
    @relationship.follower_id = nil
    assert @relationship.invalid?
  end
end
