class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  attr_accessor :remember_token, :activation_token, :reset_token
  before_create :create_activation_digest
  before_save   :downcase_email

  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true


  class << self
    # Returns hash digest of given string
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # Returns random token
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # Sets remember_digest to token hash
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  # Returns remember digest or sets new one
  def session_token
    remember_digest || remember
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if (digest.nil?)
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Clears remember digest
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Send activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Set password digest
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Send eamil with password reaet link
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if password reset has expired
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Define feed
  # See 'Following users' for full implementation
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
                    .includes(:user, image_attachment: :blob)
  end

  # Follow a user
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # Unfollow a user
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if current_user is following second user
  def following?(other_user)
    following.include?(other_user)
  end

  private
    # Downcase email
    def downcase_email
      email.downcase!
    end

    # Create and assign acitvation token and digest
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
