class ApplicationController < ActionController::API
  after_action :set_access_control_headers
  before_action :check_authenticate!

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

  private

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'https://grow-gilt.vercel.app'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Content-Type'
    headers['Access-Control-Max-Age'] = '1728000'
  end
end
