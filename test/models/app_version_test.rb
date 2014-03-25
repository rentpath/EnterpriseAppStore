require 'test_helper'

class AppVersionTest < ActiveSupport::TestCase

  test "should return an incremented version for android" do
    v = app_versions :app_version_2
    v.instance_variable_set(:@project, projects(:project_1))
    old_version = v.version
    v.create_version
    assert_equal(v.version, "5.5.6-ENT")
  end

  test "should return an incremented version for ios" do
    v = app_versions :app_version_1
    v.instance_variable_set(:@project, projects(:project_1))
    old_version = v.version
    v.create_version
    assert_equal(v.version, "3.3.3-RC.2")
  end

  test "should return the passed in version if the project has no previous versions" do
    p = projects :project_3
    v = AppVersion.new
    v.app_artifact_file_name = "test.apk"
    v.instance_variable_set(:@project, projects(:project_2))
    v.version = "1.0.0-SOMETHING"
    v.project_id = 3
    v.create_version
    assert_equal(v.version, "1.0.0-SOMETHING")
  end

  test "should set the project running version for ios" do
    v = app_versions :app_version_1
    v.instance_variable_set(:@project, projects(:project_1))
    old_version = v.version
    v.create_version
    proj = v.instance_variable_get(:@project)
    assert_equal(proj.running_version_ios, "3.3.3-RC.2")
    assert_equal(proj.running_version_android, "5.5.5-ENT")
  end

  test "should set the project running version for android" do
    v = app_versions :app_version_2
    v.instance_variable_set(:@project, projects(:project_1))
    old_version = v.version
    v.create_version
    proj = v.instance_variable_get(:@project)
    assert_equal(proj.running_version_ios, "3.3.3-RC.1")
    assert_equal(proj.running_version_android, "5.5.6-ENT")
  end
end
