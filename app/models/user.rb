class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  # Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  # Rememberable
  field :remember_created_at, type: Time

  # Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  field :mobile, type: String
  field :auth_token, type: String

  # Processes and Validations
  before_create :set_auth_token!, :email_unique
  before_validation :downcase_email

  # Validations
  validates :email, length: { maximum: 255 }
  validates :mobile, length: { maximum: 25 }
  validates :auth_token, uniqueness: true
  validates_uniqueness_of :email, if: 'email.present?'
  validates_presence_of :password, on: :create

  index({ email: 1 }, unique: true, name: 'email_index', background: true, sparse: true)
  index({ auth_token: 1 }, unique: true, name: 'auth_token_index', background: true, sparse: true)

  def set_auth_token!
    begin
      self.auth_token = Devise.friendly_token
    end while User.where(auth_token: self.auth_token).first.present?
  end

  def user_json
    {
      _id: _id.to_s,
      authToken: auth_token,
      createdAt: created_at,
      email: email,
      mobile: mobile,
      updatedAt: updated_at
    }
  end

  private

  def downcase_email
    self.email = email.strip.downcase if email.present?
  end

  def auth_token_unique
    if self.auth_token.present?
      if User.where(auth_token: self.auth_token).first.present?
        errors.add(:auth_token, 'is not unique')
      end
    end
  end

  def email_unique
    if User.where(email: self.email).first.present?
      errors.add(:email, 'is not unique')
    end
  end
end
