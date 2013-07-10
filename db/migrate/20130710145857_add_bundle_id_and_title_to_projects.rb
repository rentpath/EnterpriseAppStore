class AddBundleIdAndTitleToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :bundle_identifier, :string
    add_column :projects, :title, :string
  end
end
