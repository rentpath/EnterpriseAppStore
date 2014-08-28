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
        notes: '871af1ea16f6190a315c540ba040caee719c68ab test'
        }, format: :json
    end
    json=JSON.parse(@response.body); 
    assert( ['url','version'].each { |k| json.has_key? k } )
    assert_equal('33.33.33-ENT', json['version'])
  end 

  test "should create app_version for ios" do
    assert_difference('AppVersion.count') do
      post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.ipa'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '33.33.33-ENT',
        notes: '871af1ea16f6190a315c540ba040caee719c68bcd test'
        }, format: :json
    end
    json=JSON.parse(@response.body); 
    assert( ['url','version'].each { |k| json.has_key? k } )
    assert_equal('33.33.33-ENT', json['version'])
  end 


  test "should return an unprocessable entry if the project cannot be found" do
    no_possible_way_this_project_could_exist = "3423423"
    get :index, project_id: no_possible_way_this_project_could_exist
    assert_equal(JSON.parse(@response.body)['error'], 'could not find project')  
  end

  test "should not create an app_version if trying to send a version with a duplicate sha on the same project" do
    assert_difference('AppVersion.count') do
      post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.ipa'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '6.7.8',
        notes: '871af1ea16f6190a315c540ba040caee719c6812 test'
        }, format: :json
    end
    assert_no_difference('AppVersion.count') do
      post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.ipa'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '1.2.3',
        notes: '871af1ea16f6190a315c540ba040caee719c6812 test'
        }, format: :json
    end
  end

  test "a json validation error should be returned when trying to submit a version for a duplicate sha but with a different version" do
    post :create, project_id: 1, app_version: {
        app_artifact: fixture_file_upload('files/test.ipa'),
        version_icon: fixture_file_upload('files/test.png'),
        version: '1.2.3',
        notes: '871af1ea16f6190a315c540ba040caee719c68bf test'
        }, format: :json
    json=JSON.parse(@response.body);
    assert( ['error'].each { |k| json.has_key? k } )
    assert_equal("Validation failed: Sha has already been taken, \
Version You asked to create version: 1.2.3, on sha: 871af1ea16f6190a315c540ba040caee719c68bf, but we already have this version: 1.2.3.4 for the same sha", json['error'])
  end

end