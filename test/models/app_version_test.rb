require 'test_helper'

class AppVersionTest < ActiveSupport::TestCase

  test "should fail to validate if new app version duplicates an existing sha and existing version" do
    assert_raises(ActiveRecord::RecordInvalid) {
      app_versions(:app_version_1).save!
    }
  end

  test "should fail to validate if the new app version duplicates an existing version" do
    av1 = app_versions(:app_version_1)
    av1.sha = "testav1"
    assert_raises(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end


  test "should fail to validate if the new app version duplicates an existing sha" do
    av1 = app_versions(:app_version_1)
    av1.version = "4.2.1"
    assert_raises(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end  

  test "should pass validation if duplicate versions and shas for differing projects are used" do
    av1 = app_versions(:app_version_1)
    av1.project_id = "99"
    assert_nothing_raised(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end

  test "should fail to validate if a different version for the same sha is used regardless of the project" do
    av1 = app_versions(:app_version_1)
    av1.project_id = "99"
    av1.version = "4.3.2"
    assert_raises(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end

  test "should fail to validate if a sha is nil" do
    av1 = app_versions(:app_version_1)
    av1.sha = nil
    assert_raises(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end

  test "should fail to validate if a version is nil" do
    av1 = app_versions(:app_version_1)
    av1.version = nil
    assert_raises(ActiveRecord::RecordInvalid) {
      av1.save!
    }
  end


end
