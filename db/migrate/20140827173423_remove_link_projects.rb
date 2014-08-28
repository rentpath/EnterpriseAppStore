class RemoveLinkProjects < ActiveRecord::Migration
  def change
    drop_table :linked_projects
    remove_column :projects, :running_version_ios
    remove_column :projects, :running_version_android
  end
end
