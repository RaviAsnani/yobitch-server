class UsersController < ApplicationController

  def invite
    data = {
      :sender_id => params[:id]
    }
    data = data.to_json
    data = URI.encode(data)
    redirect_to "https://play.google.com/store/apps/details?id=com.threed.bowling&referrer=#{data}"
  end

end

