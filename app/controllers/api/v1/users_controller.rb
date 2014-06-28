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
      # UserContact.where(:email => params[:user][:contacts], :user_id => @user.id).delete_all
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

  private

  def user_params
    params.fetch(:user).permit(:name, :email, :gcm_token)
  end

end

