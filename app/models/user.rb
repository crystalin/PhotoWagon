class User < ActiveRecord::Base
  ROLES = %w[admin]

  attr_accessible :name, :email, :password, :password_confirmation

  attr_accessor :password
  before_save :encrypt_password

  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email

  def self.authenticate(login, password)
    user = find_by_email(login)
    user ||= find_by_name(login)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def role?(base_role)
    base_role.to_s == role
  end
end