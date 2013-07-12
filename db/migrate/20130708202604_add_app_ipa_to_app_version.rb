class AddAppIpaToAppVersion < ActiveRecord::Migration
  def self.up
    add_attachment :app_versions, :app_ipa
  end

  def self.down
    remove_attachment :app_versions, :app_ipa
  end
end
