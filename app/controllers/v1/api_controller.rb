# frozen_string_literal: true

module V1
  class ApiController < ApplicationController
    before_action :check_authenticate!
    rescue_from StandardError, with: :render_500
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_csrf_token
    rescue_from ActiveRecord::RecordInvalid, with: :render_422
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::BadRequest, with: :render_400

    private

    def check_authenticate!
      token = request.cookies['token']

      if token.blank?
        render json: { errors: 'Authorization token is missing' }, status: :unauthorized
        return
      end
      begin
        decoded = JsonWebToken.decode(token)
        User.find_by(email: decoded[:user_email])
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    def handle_invalid_csrf_token(_exception)
      render json: { errors: 'Invalid CSRF token' }, status: :unprocessable_entity
    end

    def render_500(errors)
      logger.error(errors) # 例外をログに出力
      render json: { errors: 'Internal Server Error' }, status: :internal_server_error
    end

    def render_422(errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end

    def render_404(errors)
      render json: { errors: errors }, status: :not_found
    end

    def render_400(errors)
      render json: { errors: errors }, status: :bad_request
    end
  end
end
