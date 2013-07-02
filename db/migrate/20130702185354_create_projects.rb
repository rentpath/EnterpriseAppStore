class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name, limit: 50, null: false
      t.timestamps
    end
  end
end
