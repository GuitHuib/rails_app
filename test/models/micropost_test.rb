require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    @post = @user.microposts.build(content: "some stuff here")
  end

  test "should be valid" do
    assert @post.valid?
  end

  test "user id should be present" do
    @post.user_id = nil
    assert_not @post.valid?
  end

  test "content should be present" do
    @post.content = "  "
    assert_not @post.valid?
  end

  test "content should be no longer than 140 charachters" do
    @post.content = "a" * 141
    assert_not @post.valid?
  end

  test "microposts should display most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

end
