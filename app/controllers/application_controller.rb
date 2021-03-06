class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!
  before_filter :prepare_for_mobile
  before_filter :find_projects

  private
  def find_projects
    @all_projects = Project.all.sort_by(&:name)
    proj = OpenStruct.new(id: "", name: 'all projects')
    default = OpenStruct.new(id: "", name: '---')
    @all_projects.unshift(proj)
    @all_projects.unshift(default)
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end

  def authenticate_user_from_token!
    user = User.find_by_authentication_token(params[:authentication_token])
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token])
      sign_in user, store: false
    end
  end

end
