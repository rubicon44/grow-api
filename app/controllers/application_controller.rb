class ApplicationController < ActionController::API
  # before_action :check_authenticate!

  def check_authenticate!
    token = request.headers["Authorization"]
    begin
      @decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(email: @decoded[:user_email])
      return @current_user
    rescue ActiveRecord::RecordNotFound => e
      render json: {errors: e.message}, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: {errors: e.message}, status: :unauthorized
    end
  end
end
