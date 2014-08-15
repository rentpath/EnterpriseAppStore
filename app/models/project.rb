class Project < ActiveRecord::Base
  attr_accessible :name, :project_icon, :bundle_identifier, :title, :running_version_ios, :running_version_android, :linked_projects, :unified_version_ios, :unified_version_android, :authoritative_project

  has_many :linked_projects

  def running_version(isAndroid, version)
    isAndroid ? self.running_version_android = version : self.running_version_ios = version
    self.save!
  end

  def add_error(field, msg)
    self.errors.add(field, msg)
  end

  def option_link
    "<a href='blah'>#{name}</a>"
  end

  def unified_version_ios
    authoritative_project.running_version_ios
  end

  def unified_version_android
    authoritative_project.running_version_android
  end

  def unified_version_ios=(version)
    self.running_version_ios = version
  end

  def unified_version_android=(version)
    self.running_version_android = version
  end

  def first_linked_project
    @first_linked_project ||= begin
      return if self.linked_projects.empty?
      id = self.linked_projects.map(&:linked_project_id).min
      Project.where(id: id).first
    end
  end

  def authoritative_project
    @authoritative_project ||= begin
      return self unless self.first_linked_project
      self.id < self.first_linked_project.id ? self :
      self.first_linked_project
    end
  end

  def authoritative?
    self.id == authoritative_project.id if authoritative_project
  end

  has_many :app_versions, dependent: :destroy
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
