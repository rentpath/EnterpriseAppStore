require 'test_helper'

class AppVersionTest < ActiveSupport::TestCase
  test "should return an incremented version for android" do
    v = app_versions :app_version_2
    old_version = v.version
    v.create_version
    assert_equal(v.version, "100.100.100-ENTERPRISE")
  end

  test "should return an incremented version for ios" do
    v = app_versions :app_version_1
    old_version = v.version
    v.create_version
    assert_equal(v.version, "100.100.105-TEST.4")
  end

  test "should return the passed in version if the project has no previous versions" do
    p = projects :project_3
    v = AppVersion.new
    v.app_artifact_file_name = "test.apk"
    v.version = "1.0.0-SOMETHING"
    v.project_id = 3
    v.create_version
    assert_equal(v.version, "1.0.0-SOMETHING")
  end
end
