require 'test_helper'

class MicropostInteractionTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end




  test "micropost_interaction" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid post
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'
    # Valid post
    content = "This is a micropost"
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost:
                                      { content: content, image: image } }
    end
    assert assigns(:micropost).image.attached?
    assert_redirected_to root_path
    follow_redirect!
    assert_match content, response.body
    # Delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page:1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Different user, no delete link
    get user_path(users(:ryan))
    assert_select 'a', { text: 'delete', count:0 }
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # User with zero posts
    @other_user = users(:quinn)
    log_in_as(@other_user)
    get root_path
    assert_match "0 microposts", response.body
    @other_user.microposts.create!(content: "First post!")
    get root_path
    assert_match "1 micropost", response.body
  end
end
