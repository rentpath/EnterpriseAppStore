class AddShaToAppVersions < ActiveRecord::Migration
  def change
    add_column :app_versions, :sha, :string
  end
end
