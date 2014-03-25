class AddRunningVersion < ActiveRecord::Migration
  def change
    add_column :projects, :running_version_ios, :string
    add_column :projects, :running_version_android, :string
  end
end
