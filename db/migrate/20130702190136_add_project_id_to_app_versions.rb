class AddProjectIdToAppVersions < ActiveRecord::Migration
  add_column :app_versions, :project_id, :integer
end
