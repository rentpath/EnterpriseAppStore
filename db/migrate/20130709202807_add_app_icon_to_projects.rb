class AddAppIconToProjects < ActiveRecord::Migration
  def self.up
    add_attachment :projects, :project_icon
  end

  def self.down
    remove_attachment :projects, :project_icon
  end
end
