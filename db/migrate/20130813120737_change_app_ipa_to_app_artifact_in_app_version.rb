class ChangeAppIpaToAppArtifactInAppVersion < ActiveRecord::Migration
  def change
    remove_attachment :app_versions, :app_ipa
    add_attachment :app_versions, :app_artifact
  end
end
