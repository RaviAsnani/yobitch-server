class User < ActiveRecord::Base
  include Clearance::User

  before_save :ensure_authentication_token
  attr_accessor :password_confirmation

  private

  def ensure_authentication_token
    unless self.auth_token.present?
      begin
        self.auth_token = SecureRandom.hex
      end while self.class.exists?(auth_token: auth_token)
    end
  end

end
