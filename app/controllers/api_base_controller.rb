class ApiBaseController < ApplicationController

  protect_from_forgery with: :null_session

  before_filter :set_user
  skip_before_filter  :verify_authenticity_token

  rescue_from Exception, :with => :handle_public_excepton

  protected

  def handle_public_excepton(e)
    logger.error e.backtrace.join("\n")
    render json: { error: { code: ERROR_INTERNAL ,messages: [e.message]} }
  end

  private

  def set_user
    @user = User.find_by_auth_token(params[:auth_token])
    unless @user
      render json: { error: { code: ERROR_UNAUTHORIZED,  messages: ['User is invalid'] } }, status: :unprocessable_entity
    end
  end
end
