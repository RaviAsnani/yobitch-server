class User < ActiveRecord::Base
  include Clearance::User

  before_save :ensure_authentication_token
  has_many :messages
  
  has_many :user_friends
  has_many :friends, :through => :user_friends

  attr_accessor :password_confirmation

  def all_messages
    if is_free
      Message.where(user_id: nil)
    else
      messages + Message.where(user_id: nil)
    end
  end

  def add_friend_by_email(email)
    user = User.find_by_email(email)
    if user.present?
      add_friend(user)      
    else
      false
    end
  end

  def add_friend(friend)
    user_friend = UserFriend.new
    user_friend.user_id = self.id
    user_friend.friend_id = friend.id
    user_friend.save
    user_friend = UserFriend.new
    user_friend.user_id = friend.id
    user_friend.friend_id = self.id
    user_friend.save
    true
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
