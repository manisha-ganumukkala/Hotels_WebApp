require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  test "should get contactus" do
    get welcome_contactus_url
    assert_response :success
  end

end
