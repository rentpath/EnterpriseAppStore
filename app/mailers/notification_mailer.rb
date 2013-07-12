class NotificationMailer < ActionMailer::Base
  default :from => 'noreply@rentpath.com'

  def send_notification
    all_users = User.all
    all_users.each do |user|
      @version = AppVersion.last
      mail(:to      => user.email,
           :subject => "Version #{@version.version} Now Available")
    end
  end

end