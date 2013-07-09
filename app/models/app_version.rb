class AppVersion < ActiveRecord::Base
  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_ipa

  has_attached_file :app_ipa,
                    :storage => :s3,
                    :s3_credentials => {
                        :bucket => ENV['AWS_BUCKET'],
                        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    :path => "/:class/:attachment/:id_partition/:style/:timestamp/:filename"

  # VALIDATIONS
  version_regex =  /\d+.\d+.\d+/
  validates :version,
            :presence => true,
            :format => {:with => version_regex},
            :uniqueness => {:case_sensitive => false}

  validates :app_ipa,
            :presence => true,
            :format => {:with => /\.(ipa)/i, :message => "Only a .ipa can be uploaded"}


end
