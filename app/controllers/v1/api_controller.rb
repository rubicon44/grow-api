# frozen_string_literal: true

module V1
  class ApiController < ApplicationController
    before_action :check_authenticate!
    rescue_from StandardError, with: :render500
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_csrf_token
    rescue_from ActiveRecord::RecordInvalid, with: :render422
    rescue_from ActiveRecord::RecordNotFound, with: :render404
    rescue_from ActionController::BadRequest, with: :render400

    private

    def check_authenticate!
      token = request.cookies['token']

      return render_unauthorized('Authorization token is missing') if token.blank?

      begin
        decoded = JsonWebToken.decode(token)
        User.find_by(email: decoded[:user_email])
      rescue ActiveRecord::RecordNotFound => e
        render_unauthorized(e.message)
      rescue JWT::DecodeError => e
        render_unauthorized(e.message)
      end
    end

    def render_unauthorized(errors)
      render json: { errors: errors }, status: :unauthorized
    end

    def handle_invalid_csrf_token(_exception)
      render json: { errors: 'Invalid CSRF token' }, status: :unprocessable_entity
    end

    def render500(errors)
      logger.error(errors) # 例外をログに出力
      render json: { errors: 'Internal Server Error' }, status: :internal_server_error
    end

    def render422(errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end

    def render404(errors)
      render json: { errors: errors }, status: :not_found
    end

    def render400(errors)
      render json: { errors: errors }, status: :bad_request
    end
  end
end
