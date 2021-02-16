require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:Tuesday)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "lorem ipsum" } }
    end
    assert_redirected_to login_path
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_path
  end

  test "should redirect delete for wrong posts" do
    log_in_as(users(:michael))
    post = microposts(:Nott)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(post)
    end
    assert_redirected_to root_path
  end
end
