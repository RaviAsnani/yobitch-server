class Message < ActiveRecord::Base
  belongs_to :user

  def self.random
    Message.where(user_id: nil).sample
  end

end
