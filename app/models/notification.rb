class Notification < ActiveRecord::Base
  belongs_to :message
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"

  self.inheritance_column = "something_else"

  def send_abuse
    data = {
      :sender => {
        :id => self.sender.id,
        :name => self.sender.name,
        :email => self.sender.email
      },
      :receiver => {
        :id => self.receiver.id,
        :name => self.receiver.name,
        :email => self.receiver.email
      },
      :message => nil,
      :title => "#{self.sender.name} abused you!",
      :klass => self.type,
      :id => self.id
    }
    if sender.is_elevated
      data[:message] = self.message.abuse
    else
      data[:message] = self.message.sensored_abuse
    end
    send_message({:data => data}, self.receiver.gcm_token)
  end

  def friend_joined
    data = {
      :sender => {
        :id => self.sender.id,
        :name => self.sender.name,
        :email => self.sender.email
      },
      :receiver => {
        :id => self.receiver.id,
        :name => self.receiver.name,
        :email => self.receiver.email
      },
      :message => "#{self.sender.name} is online",
      :title => "Let the B*tching begin!",
      :klass => self.type,
      :id => self.id
    }
    send_message({:data => data}, self.receiver.gcm_token)
  end

  private

  def send_message(data, gcm_token)
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
          self.sent = true
          self.save
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

end
