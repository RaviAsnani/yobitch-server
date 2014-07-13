class UsersController < ApplicationController

  def invite
    redirect_to "https://play.google.com/store/apps/details?id=com.threed.bowling&referrer=#{params[:id]}"
  end

end

