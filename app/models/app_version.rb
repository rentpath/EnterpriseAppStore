class AppVersion < ActiveRecord::Base
  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_plist, :app_plist_file_name, :app_artifact, :version_icon, :project_id, :created_at
  
  before_validation(on: :create) do
    return self.version
    return unless self.version or not self.app_artifact_file_name
    create_version
  end

  def create_version
    last_version = find_last_version
    return self.version unless last_version or last_version.length < 1
    self.version = last_version
    index = self.version.rindex(/\.(\d+)/); micro = $1; micro=(micro.to_i+1).to_s
    self.version = self.version[0..index] + micro + self.version[index+1+micro.length..-1]
  end

  def find_last_version
    isSelfAndroid = isAndroid self.app_artifact_file_name
    AppVersion.where(project_id: self.project_id).order(:id).reverse_order.each do |version|
      return version.version unless(isSelfAndroid ^ isAndroid(version.app_artifact_file_name))
    end
  end

  def isAndroid(file) 
    file[-4..-1] == ".apk"
  end

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
