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
      data = {
        :sender => {
          :id => sender.id,
          :name => sender.name,
          :email => sender.email
        },
        :receiver => {
          :id => self.id,
          :name => self.name,
          :email => self.email
        },
        :message => nil,
        :title => "#{sender.name} abused you!" 
      }
      if sender.is_elevated
        data[:message] = message.abuse
      else
        data[:message] = message.sensored_abuse
      end
      send_message(data)
    else
      false
    end
  end

  def send_message(data)
    if gcm_token.present?
      options = { 
        :data => data 
      }
      request = HiGCM::Sender.new(Settings[:gcm][:api_key])
      begin  
        response = request.send([gcm_token], options)
        response = JSON.parse(response.body)
        if response["failure"] == 1
          logger.info "[Error Send Message] #{response} #{data}"
          false
        else
          logger.info "[Success Send Message] #{response} #{data}"
          true
        end
      rescue Exception => e
        logger.info "[Error Send Message] #{e.message}"
        # retry
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
