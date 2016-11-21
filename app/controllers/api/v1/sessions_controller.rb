class Api::V1::SessionsController < ApplicationController
  respond_to :json

  def create
    email = session_params[:email]
    password = session_params[:password]
    user = User.where(email: email).first

    if email.present? && user.present?
      if user.valid_password?(password)
        sign_in user, store: false
        user.set_auth_token!
        user.save

        render json: user.user_json, status: 200
      else
        render json: { errors: 'Invalid email or password' }, status: 422
      end
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end

  def destroy
    user = User.where(auth_token: params[:id]).first
    user.set_auth_token!
    if user.save
      head 204
    else
      render json: { errors: user.errors }, status: 500
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
