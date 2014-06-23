require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
    @other_user = users(:two)
    sign_in @user
  end

  test "creating a relationship with Ajax" do
    assert_difference "Relationship.count" do
      xhr :post, :create, relationship: { followed_id: @other_user.id }
    end
    assert_response :success
  end

  test "destroying a relationship with Ajax" do
    @user.follow!(@other_user)
    relationship = @user.relationships.find_by(followed_id: @other_user.id)
    assert_difference "Relationship.count", -1 do
      xhr :delete, :destroy, id: relationship.id
    end
    assert_response :success
  end
end
