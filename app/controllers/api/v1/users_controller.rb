class Api::V1::UsersController < ApiBaseController
  skip_before_filter :set_user, only: [:create]

  def create
    @user = User.find_by_email(user_params[:email]) 
    unless @user.present?
      @user = User.new(user_params)
      @user.password = "yobitch"
    end
    if @user.save
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

  def invite
    redirect_to "https://play.google.com/store/apps/details?id=com.threed.bowling&referrer=#{param[:id]}"
  end

  private

  def user_params
    params.fetch(:user).permit(:name, :email, :gcm_token)
  end

end

