class WelcomeController < ApplicationController
  def index
    @app_versions = AppVersion.all
  end
end
