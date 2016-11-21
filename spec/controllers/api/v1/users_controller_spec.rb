require 'spec_helper'

describe Api::V1::UsersController do
  before do
    request.headers['Accept'] = 'application/vnd.rails-auth.v1'
  end

  describe 'GET #index' do
    before do
      User.destroy_all

      30.times do
        FactoryGirl.create(:user)
      end
    end

    after do
      User.destroy_all
    end

    context 'when no params passed' do
      before do
        get :index
      end

      it 'returns 1 page of users' do
        results = JSON.parse(response.body, symbolize_names: true)
        expect(results.length).to eq(20)
      end
    end

    context 'when page param passed' do
      before do
        get :index, { page: 2 }
      end

      it 'returns the second page of users' do
        results = JSON.parse(response.body, symbolize_names: true)
        expect(results.length).to eq(10)
      end
    end
  end

  describe 'GET #show' do
    before do
      @user = FactoryGirl.create(:user)
      get :show, id: @user._id, format: :json
    end

    after do
      @user.destroy
    end

    it 'returns a user\'s information as a hash' do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eq(@user.email)
    end

    it { should respond_with 200 }
  end

  describe 'POST #create' do
    context 'when successfully created' do
      before do
        @user_attributes = FactoryGirl.attributes_for(:user)
        post :create, { user: @user_attributes }, format: :json
      end

      it 'returns a JSON object for the user just created' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq(@user_attributes[:email])
      end

      it { should respond_with 201 }
    end

    context 'when not created' do
      before do
        @invalid_user_attributes = {
          password: 'password123',
          password_confirmation: 'password123'
        }

        post :create, { user: @invalid_user_attributes }, format: :json
      end

      it 'returns a JSON object with an error' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
        expect(user_response[:errors][:email]).to include('can\'t be blank')
      end

      it { should respond_with 422 }
    end
  end

  describe 'PUT/PATCH #update' do
    context 'when is successfully updated' do
      before do
        @user = FactoryGirl.create(:user)
        request.headers['Authorization'] =  @user.auth_token
        patch :update, { id: @user, user: { email: 'some_email@example.com' } }, format: :json
      end

      after do
        @user.destroy
      end

      it 'returns a JSON object for the updated user' do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq('some_email@example.com')
      end

      it { should respond_with 200 }
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      request.headers['Authorization'] =  @user.auth_token
      delete :destroy, { id: @user._id }, format: :json
    end

    it { should respond_with 204 }
  end
end
