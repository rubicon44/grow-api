module V1
  class ApiController < ApplicationController
    before_action :check_authenticate!
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordInvalid, with: :render_422
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::BadRequest, with: :render_400

    private

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

    def render_500(errors)
      logger.error(errors) # 例外をログに出力
      render json: { error: 'Internal Server Error' }, status: 500
    end

    def render_422(errors)
      render json: { errors: errors }, status: 422
    end

    def render_404
      render json: { error: 'Record not found' }, status: 404
    end

    def render_404(errors)
      render json: { error: errors }, status: 404
    end

    def render_400(errors)
      render json: { error: errors }, status: 400
    end
  end
end