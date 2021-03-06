class AppVersion < ActiveRecord::Base
  include Plist

  attr_accessible :name, :version, :url_ipa, :url_plist, :url_icon, :notes, :app_plist, :app_plist_file_name, :app_artifact, :version_icon, :project_id, :created_at, :sha

  def isAndroid?
    file = self.app_artifact_file_name
    file ? file[-4..-1] == ".apk" : nil
  end

  def find_project
    @project ||= Project.find(self.project_id)
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
                    storage: :s3,
                    s3_credentials: {
                        bucket: ENV['AWS_BUCKET'],
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    path: "/:class/:attachment/:id_partition/:style/:filename"

  has_attached_file :version_icon,
                    storage: :s3,
                    s3_credentials: {
                        bucket: ENV['AWS_BUCKET'],
                        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
                    },
                    styles: { medium: "114x114>",
                                 thumb: "57x57>" },
                    path: "/:class/:attachment/:id_partition/:style/:filename"


  validates :sha, presence: true, uniqueness: {case_sensitive: false, scope: :project_id}

  version_regex =  /\d+.\d+.\d+/

  validates :version,
            presence: true,
            format: {with: version_regex},            
            uniqueness: {case_sensitive: false, scope: :project_id}

  validate :matches_version_for_same_sha

  validates :app_artifact,
            presence: true,
            format: {with: /\.(ipa|apk)/i, message: "Only a .ipa or .apk can be uploaded"}

  validates :version_icon,
            presence: true,
            format: {with: /\.(jpg|png|jpeg)/i, message: "Only a .ipa can be uploaded"}

  def matches_version_for_same_sha
    matching_sha = AppVersion.where(sha: sha).first
    errors.add(:version, "You asked to create version: #{version}, on sha: #{sha}, but we already have \
this version: #{matching_sha.version} for the same sha") unless
    matching_sha.nil? or (matching_sha.version == version)
  end


end
