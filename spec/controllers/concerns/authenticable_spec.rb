require 'spec_helper'

module Api::V1
  describe Concerns::Authenticable, type: :controller do
    controller(ApplicationController) do
      include Concerns::Authenticable

      before_action :authenticate_with_token!, only: [:get_user]

      def get_user
        render json: current_user.user_json
      end
    end

    before do
      routes.draw do
        get 'get_user' => 'anonymous#get_user'
      end
    end

    describe '#current_user' do
      context 'when there\'s an auth token in the requst header' do
        before do
          @user = FactoryGirl.create(:user)
          request.headers['Authorization'] = @user.auth_token
          get :get_user
        end

        after do
          @user.destroy
        end

        it 'returns the user from the authorization header' do
          auth_response = JSON.parse(response.body, symbolize_names: true)
          expect(auth_response[:email]).to eq(@user.email)
        end

        it 'returns a 200 status code' do
          expect(response.status).to eq(200)
        end
      end

      context 'when there\'s no auth token in the requst header' do
        before do
          @user = FactoryGirl.create(:user)
          request.headers['Authorization'] = nil
          get :get_user
        end

        after do
          @user.destroy
        end

        it 'returns nil body' do
          expect(response.body.empty?).to be(true)
        end

        it 'returns an unauthorized status code' do
          expect(response.status).to eq(401)
        end
      end
    end
  end
end
