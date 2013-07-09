class Project < ActiveRecord::Base
  attr_accessible :name, :project_icon
  has_many :app_versions
  has_attached_file :project_icon,
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    :styles => { :medium => "114x114>",
                                 :thumb => "57x57>" },
                    :path => "/:class/:attachment/:id_partition/:style/:timestamp/:filename"
end
