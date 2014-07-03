class AppVersion < ActiveRecord::Base
  include Plist

  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_plist, :app_plist_file_name, :app_artifact, :version_icon, :project_id, :created_at

  before_validation(on: :create) do
    find_project
    return if !self.app_artifact_file_name or !@project
    create_version
  end

  def create_version
    last_version = running_project_version
    return if !last_version or last_version.length < 1
    self.version = last_version
    increment_version    
    set_running_version
  end

  def increment_version
    index = self.version.rindex(/\.(\d+)/); micro = $1; new_micro=(micro.to_i+1).to_s
    self.version = self.version[0..index] + new_micro + self.version[index+1+micro.length..-1]
  end

  def decrement_version
    index = self.version.rindex(/\.(\d+)/); micro = $1; new_micro=(micro.to_i-1)
    return self.version if new_micro < 0
    self.version = self.version[0..index] + new_micro.to_s + self.version[index+1+micro.length..-1]    
  end

  def set_running_version
    isAndroid? ? @project.running_version_android = self.version : @project.running_version_ios = self.version
    @project.save
  end

  def isAndroid?
    file = self.app_artifact_file_name
    file ? file[-4..-1] == ".apk" : nil
  end

  def find_project
    @project ||= Project.find(self.project_id)
  end

  def running_project_version
    isAndroid? ? find_project.running_version_android : find_project.running_version_ios
  end

  def decrement_project_version_if_needed
    (decrement_version; set_running_version) if running_project_version == self.version
  end

  def build_plist(url)
    return if isAndroid?
    find_project
    return unless @project

    plist_root = "#{Rails.root}/public/plist"
    plist_template = "#{plist_root}/template.plist"
    plist = Plist::parse_xml(plist_template)

    plist['items'][0]['assets'][0]['url'] = self.app_artifact.url
    plist['items'][0]['metadata']['bundle-identifier'] = @project.bundle_identifier
    plist['items'][0]['metadata']['bundle-version'] = self.version
    plist['items'][0]['metadata']['title'] = @project.title

    self.plist_content = plist.to_plist
    self.url_plist = "itms-services://?action=download-manifest&amp;url=#{url}?#{Time.now.to_i.to_s}" 
  end

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
            :uniqueness => {:case_sensitive => false, :scope => :project_id}

  validates :app_artifact,
            :presence => true,
            :format => {:with => /\.(ipa|apk)/i, :message => "Only a .ipa or .apk can be uploaded"}

  validates :version_icon,
            :presence => true,
            :format => {:with => /\.(jpg|png|jpeg)/i, :message => "Only a .ipa can be uploaded"}

end
