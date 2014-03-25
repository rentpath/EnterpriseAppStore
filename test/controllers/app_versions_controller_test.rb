require 'test_helper'

class AppVersionsControllerTest < ActionController::TestCase
  setup do
    sign_in users :user1
  end

  test "should create app_version for android" do
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
    assert_equal(json['version'], '5.5.6-ENT')
  end 

  test "should create app_version for ios" do
    assert_difference('AppVersion.count') do
      post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.ipa'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '33.33.33-ENT',
        notes: 'test'
        }, format: :json
    end
    json=JSON.parse(@response.body); 
    assert( ['url','version'].each { |k| json.has_key? k } )
    assert_equal(json['version'], '3.3.3-RC.2')
  end 


  test "should return an unprocessable entry if the project cannot be found" do
    no_possible_way_this_project_could_exist = "3423423"
    get :index, project_id: no_possible_way_this_project_could_exist
    assert_equal(JSON.parse(@response.body)['error'], 'could not find project')  
  end
end