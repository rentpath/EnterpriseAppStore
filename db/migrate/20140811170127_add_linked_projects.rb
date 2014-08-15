class AddLinkedProjects < ActiveRecord::Migration
  def change
    create_table :linked_projects do |t|
      t.integer :project_id, null: false
      t.integer :linked_project_id, null: false
      t.timestamps
    end
  end
end
