class Project < ActiveRecord::Base
  attr_accessible :name
  has_many :app_versions
end
