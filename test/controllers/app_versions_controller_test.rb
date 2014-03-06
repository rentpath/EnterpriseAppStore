require 'test_helper'

class AppVersionsControllerTest < ActionController::TestCase
  setup do
    sign_in users :user1
  end

  test "should create app_version" do
    assert_difference('AppVersion.count') do
      post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.apk'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '33.33.33-ENT',
        notes: 'test'
        }, format: :json
    end
    json=JSON.parse(@response.body); 
    assert( ['url','version'].each { |k| json.has_key? k } )
  end 
end