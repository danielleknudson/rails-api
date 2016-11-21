class Api::V1::UsersController < ApplicationController
  respond_to :json

  before_action :authenticate_with_token!, only: [:update, :destroy]

  # Returns 20 results per page
  def index
    page = params.fetch(:page, 1)

    if page.present? && page != '1'
       total = page.to_i * 20
       skip = total - 20
     else
       skip = 0
     end

    users = User.skip(skip).limit(20)

    render json: users.map(&:user_json)
  end

  def show
    user = User.where(_id: params[:id]).first

    if user.present?
      render json: user.user_json
    else
    end
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: user.user_json, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update
    user = current_user

    if user.present?
      if user.update(user_params)
        render json: user.user_json, status: 200, location: [:api, user]
      else
        render json: { errors: user.errors }, status: 422
      end
    else
      render json: { errors: 'User not found' }, status: 404
    end
  end

  def destroy
    user = current_user

    if user.present?
      if user.destroy
        render json: { success: 'User destroyed'}, status: 204
      else
        render json: { errors: 'Could not destroy user' }, status: 500
      end
    else
      render json: { errors: 'User not found' }, status: 404
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :mobile
    )
  end
end
