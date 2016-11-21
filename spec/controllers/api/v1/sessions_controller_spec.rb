require 'spec_helper'

describe Api::V1::SessionsController do
  before do
    request.headers['Accept'] = 'application/vnd.rails-auth.v1'
  end

  describe 'POST #create' do
    before do
      @user = FactoryGirl.create(:user)
    end

    after do
      @user.destroy
    end

    context 'when the credentials are incorrect' do
      before do
        credentials = { email: @user.email, password: 'passwordabc' }
        post :create, { session: credentials }, format: :json
      end

      it 'returns an error' do
        session_response = JSON.parse(response.body, symbolize_names: true)
        expect(session_response[:errors]).to eq('Invalid email or password')
      end

      it { should respond_with 422 }
    end

    context 'when the credentials are correct' do
      before do
        credentials = { email: @user.email, password: 'password123' }
        post :create, { session: credentials }, format: :json
      end

      it 'returns the user corresponding to the given credentials' do
        @user.reload
        session_response = JSON.parse(response.body, symbolize_names: true)
        expect(session_response[:authToken]).to eq(@user.auth_token)
      end

      it { should respond_with 200 }
    end
  end

  describe 'DELETE #destroy' do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      delete :destroy, { id: @user.auth_token }, format: :json
    end

    it { should respond_with 204 }
  end
end
