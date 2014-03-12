class AddPlistContent < ActiveRecord::Migration
  def change
    add_column :app_versions, :plist_content, :text
  end
end
