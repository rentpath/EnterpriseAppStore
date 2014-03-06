require 'test_helper'

class AppVersionTest < ActiveSupport::TestCase
  test "should return an incremented version for android" do
    v = app_versions :app_version_2
    old_version = v.version
    v.create_version
    assert_equal(v.version, "100.100.111-TEST")
    end

  test "should return an incremented version for ios" do
    v = app_versions :app_version_1
    old_version = v.version
    v.create_version
    assert_equal(v.version, "100.100.105-TEST.4")
  end
end
