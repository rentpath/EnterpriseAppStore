class NotificationMailer < ActionMailer::Base
  default :from => 'noreply@rentpath.com'

  def send_notification(project)
    all_users = User.all
    all_users.each do |user|
      @version = AppVersion.last
      @project = project
      mail(:to      => user.email,
           :subject => "#{@project.name} Version #{@version.version} Now Available")
    end
  end

end