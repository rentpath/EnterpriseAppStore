class RegistrationsController < ApplicationController
  skip_before_filter :authenticate_user!
  def new
    @user = User.new
    @notice = params[:notice]
  end
end