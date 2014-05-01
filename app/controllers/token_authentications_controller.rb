class TokenAuthenticationsController < ApplicationController

  def create
    @user = User.find(params[:user_id])
    generate_token(@user)
    @user.save
    redirect_to edit_user_registration_path(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.authentication_token = nil
    @user.save
    redirect_to edit_user_registration_path(@user)
  end

  private

  def generate_token(user)
    user.authentication_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(authentication_token: random_token)
    end
  end

end
