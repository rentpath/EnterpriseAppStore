class AddPlistToAppVersions < ActiveRecord::Migration
  def self.up
    add_attachment :app_versions, :app_plist
  end

  def self.down
    remove_attachment :app_versions, :app_plist
  end
end
