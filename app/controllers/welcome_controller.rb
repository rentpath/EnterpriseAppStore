class WelcomeController < ApplicationController
  def index
    redirect_to('/projects') if is_logged_in
    @app_versions = AppVersion.all
  end

  private
    def is_logged_in
      current_user
    end
end
