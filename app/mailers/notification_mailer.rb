class NotificationMailer < ActionMailer::Base
  default :from => 'noreply@rentpath.com'

  def send_notification(user, project)
    @version = AppVersion.last
    @artifact_url = @version.app_artifact.url
    if @artifact_url.rindex('.ipa')
      @artifact_url = @version.app_plist
    end

    @project = project
    mail(:to      => user.email,
         :subject => "#{@project.name} Version #{@version.version} Now Available")
  end

end