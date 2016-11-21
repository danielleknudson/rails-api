module Concerns
  module Authenticable
    extend ActiveSupport::Concern

    def authenticate_with_token!
       head :unauthorized unless current_user.present?
    end

    # Overrides Devise #current_user
    def current_user
      @current_user ||= User.where(auth_token: request.headers['Authorization']).first
    end
  end
end
