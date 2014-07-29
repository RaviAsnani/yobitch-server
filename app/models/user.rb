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

  def is_friends?(user)
    UserFriend.find_by_user_id_and_friend_id(self.id, user.id).present?
  end

  def send_abuse(sender, message)
    if is_friends?(sender)
      notification = Notification.new
      notification.sender = sender
      notification.receiver = self
      notification.message = message
      notification.type = "bitch"
      if notification.save
        if notification.receiver.id == 0
          sender.delay(run_at: [5,6,7,8,9,10].sample.seconds.from_now).send_abuse(self, Message.random)
        else
          notification.delay.send_abuse  
        end
      else
        false
      end
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
    notification = Notification.new
    notification.sender = self
    notification.receiver = friend
    notification.type = "friend_add"
    if notification.save
      notification.delay.friend_joined
    end
    true
  end

  def notify_friends
    friend_ids = UserContact.select(:user_id).where(:email => self.email).collect(&:user_id)
    contacts = UserContact.select(:email).where(:user_id => self.id).collect(&:email)
    users = User.where("id IN (?) OR email IN (?)", friend_ids, contacts)
    users.each do |user|
      unless self.is_friends?(user)
        self.add_friend(user)
      end
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
