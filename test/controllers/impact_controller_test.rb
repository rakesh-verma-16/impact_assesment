require 'test_helper'

class ImpactControllerTest < ActionDispatch::IntegrationTest
  test "should get cut" do
    get impact_cut_url
    assert_response :success
  end

end
