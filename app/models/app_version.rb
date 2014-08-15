class AppVersion < ActiveRecord::Base
  include Plist

  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_plist, :app_plist_file_name, :app_artifact, :version_icon, :project_id, :created_at

  before_validation(on: :create) do
    return if !self.app_artifact_file_name or !find_project
    create_version
  end

  def create_version
    return if !last_version or last_version.length < 1
    set_running_version(increment_version)
  end

  def increment_version(options={decrement: false})
    micro = bump_micro(find_micro, options)
    return if micro < 0
    reassemble_version(micro)
  end

  def bump_micro(micro, options)
    micro + (options[:decrement] ? -1 : 1)
  end

  def find_micro
    last_version.rindex(/\.(\d+)/)
    $1.to_i
  end

  def reassemble_version(micro)
    str = last_version.clone
    str[str.rindex(/\.\d+/)+1, 1] = micro.to_s
    str
  end

  def set_running_version(version)
    find_project.running_version(isAndroid?, version)

    find_project.linked_projects.each do |p|
      proj = Project.find(p.linked_project_id)
      next unless proj
      proj.running_version(isAndroid?, version)      
    end
    self.version = version
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

  def last_version
    isAndroid? ? linked_project.running_version_android : linked_project.running_version_ios
  end

  def linked_project
    @linked_project ||= find_project.authoritative_project
  end

  def decrement_project_version_if_needed
    set_running_version(decrement_version(decrement: true)) if running_project_version == self.version
  end

  def build_plist(url)
    return if isAndroid?
    return unless find_project

    plist_root = "#{Rails.root}/public/plist"
    plist_template = "#{plist_root}/template.plist"
    plist = Plist::parse_xml(plist_template)

    plist['items'][0]['assets'][0]['url'] = self.app_artifact.url
    plist['items'][0]['metadata']['bundle-identifier'] = find_project.bundle_identifier
    plist['items'][0]['metadata']['bundle-version'] = self.version
    plist['items'][0]['metadata']['title'] = find_project.title

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

  alias_method :decrement_version, :increment_version

end
