class Api::V1::UsersController < ApiBaseController
  skip_before_filter :set_user, only: [:create]

  def create
    @user = User.find_by_email(user_params[:email]) 
    new_user = false
    unless @user.present?
      @user = User.new(user_params)
      @user.password = "yobitch"
      new_user = true
    end
    if @user.save
      if new_user
        friend = User.find_by_id(0)
        @user.add_friend(friend) if friend.present?
        SystemMailer.delay(run_at: 3.minutes.from_now).welcome(@user)
      end
      if params[:add_friends].present?
        friends = User.where(id: params[:add_friends])
        friends.each do |friend|
          @user.add_friend(friend)
        end
      end
      @user.delay.notify_friends
      sign_in @user
      render 'created.json.jbuilder'
    else
      render json: { error: { code: ERROR_UNPROCESSABLE, messages: @user.errors.full_messages } }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update_attributes(user_params)
      render 'created.json.jbuilder'
    else
      render json: { error: { code: ERROR_UNPROCESSABLE, messages: @user.errors.full_messages } }, status: :unprocessable_entity
    end
  end

  def add_message
    message = Message.new(message_params)
    message.sensored_abuse = message.abuse
    message.user = @user
    if message.save
      @user.reload
      render 'created.json.jbuilder'
    else
      render json: { error: { code: ERROR_UNPROCESSABLE, messages: message.errors.full_messages } }, status: :unprocessable_entity  
    end
  end

  def sync_contacts
    if params[:user].present? and params[:user][:contacts].present? and params[:user][:contacts].is_a?(Array)
      user_contacts = []
      params[:user][:contacts].each do |contact|
        user_contact = UserContact.new
        user_contact.email = contact
        user_contact.user = @user
        user_contacts << user_contact
      end
      UserContact.import user_contacts
      @user.contact_sync = true
      @user.save
      @user.delay.notify_friends
    end
    render json: { code: SUCCESS_OK, messages: "Contacts Synced" }, status: :ok
  end

  def send_message
    user = User.find(params[:receiver_id])
    message = Message.find(params[:message_id])
    if user.send_abuse(@user, message)
      render json: { code: SUCCESS_OK, messages: "Sent Successfully" }, status: :ok
    else
      render json: { error: { code: ERROR_UNPROCESSABLE, messages: "Failed to send" } }, status: :unprocessable_entity
    end
  end

  def add_friend
    friend = nil
    friend = User.find_by_id(params[:id]) if params[:id].present?
    friend = User.find_by_email(params[:email]) if params[:email].present?
    if friend.present? and @user.add_friend(friend)
      render 'created.json.jbuilder'
    else
      render json: { error: { code: ERROR_UNPROCESSABLE, messages: "Failed to add friend" } }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.fetch(:user).permit(:name, :email, :gcm_token)
  end

  def message_params
    params.fetch(:message).permit(:abuse)
  end

end

