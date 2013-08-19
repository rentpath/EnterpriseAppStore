class AppVersion < ActiveRecord::Base
  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_plist, :app_plist_file_name, :app_artifact, :version_icon, :project_id

  has_attached_file :app_plist,
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    :path => "/:class/:attachment/:id_partition/:style/:filename"

  has_attached_file :app_artifact,
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    :path => "/:class/:attachment/:id_partition/:style/:filename"

  has_attached_file :version_icon,
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    :styles => { :medium => "114x114>",
                                 :thumb => "57x57>" },
                    :path => "/:class/:attachment/:id_partition/:style/:filename"

  # VALIDATIONS
  version_regex =  /\d+.\d+.\d+/
  validates :version,
            :presence => true,
            :format => {:with => version_regex},
            :uniqueness => {:case_sensitive => false}

  validates :app_artifact,
            :presence => true,
            :format => {:with => /\.(ipa|apk)/i, :message => "Only a .ipa or .apk can be uploaded"}

  validates :version_icon,
            :presence => true,
            :format => {:with => /\.(jpg|png|jpeg)/i, :message => "Only a .ipa can be uploaded"}


end
