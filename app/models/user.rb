class User < ActiveRecord::Base
  include Clearance::User

  before_save :ensure_authentication_token
  has_many :messages

  attr_accessor :password_confirmation

  def all_messages
    if is_free
      Message.where(user_id: nil)
    else
      messages + Message.where(user_id: nil)
    end
  end

  private

  def ensure_authentication_token
    unless self.auth_token.present?
      begin
        self.auth_token = SecureRandom.hex
      end while self.class.exists?(auth_token: auth_token)
    end
  end

end
