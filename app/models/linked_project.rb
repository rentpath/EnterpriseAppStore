class LinkedProject < ActiveRecord::Base
  attr_accessible :project_id, :linked_project_id
  validates :linked_project_id, uniqueness: {scope: :project_id, message: "Project already linked."}
end