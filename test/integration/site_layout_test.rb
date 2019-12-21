require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "homepage layout" do
    get root_path
    assert_template 'homes/index'

  end
end
