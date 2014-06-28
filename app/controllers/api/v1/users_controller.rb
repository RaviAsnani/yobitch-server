class Api::V1::UsersController < ApiBaseController
  skip_before_filter :set_user, only: [:create]

  def create
    @user = User.find_by_email(user_params[:email]) 
    if @user.present?
      if @user.update_attributes(user_params)
        render 'created.json.jbuilder'
      else
        render json: { error: { code: ERROR_UNPROCESSABLE, messages: @user.errors.full_messages } }, status: :unprocessable_entity
      end
    else
      @user = User.new(user_params)
      @user.password = "yobitch"
      if @user.save
        sign_in @user
        render 'created.json.jbuilder'
      else
        render json: { error: { code: ERROR_UNPROCESSABLE, messages: @user.errors.full_messages } }, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.fetch(:user).permit(:name, :email, :gcm_token)
  end

end

