require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.build(:user)
  end

  after do
    User.destroy_all
  end

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }

  it { should be_valid }

  describe 'when email is not present' do
    before do
      @user.email = nil
    end

    it { should_not be_valid }
  end

  describe 'when user is created up with an email that is associated with another user' do
    it 'returns an error' do
      new_user = User.create(email: @user.email, password: '123', password_confirmation: '123')

      expect(new_user.save).to eq(false)
    end
  end

  describe '#set_auth_token!' do
    it 'generates a unique auth token' do
      allow(Devise).to receive(:friendly_token).and_return('uniquetoken')
      @user.set_auth_token!

      expect(@user.auth_token).to eq('uniquetoken')
    end

    it 'generates another token when one has already been taken' do
      existing_user = FactoryGirl.create(:user, auth_token: 'authtoken123')
      @user.set_auth_token!
      expect(@user.auth_token).not_to eq(existing_user.auth_token)
    end
  end
end
