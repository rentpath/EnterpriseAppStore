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
end
