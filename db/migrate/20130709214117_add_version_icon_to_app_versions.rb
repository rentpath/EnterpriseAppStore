class AddVersionIconToAppVersions < ActiveRecord::Migration
  def self.up
    add_attachment :app_versions, :version_icon
  end

  def self.down
    remove_attachment :app_versions, :version_icon
  end
end
