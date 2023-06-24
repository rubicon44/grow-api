# frozen_string_literal: true

module V1
  class ApiController < ApplicationController
    before_action :check_authenticate!
    # rescue_from StandardError, with: :render500
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_csrf_token

    private

    def check_authenticate!
      token = request.headers['Authorization']

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

    # def render500(errors)
    #   logger.error(errors) # 例外をログに出力
    #   render json: { errors: 'Internal Server Error' }, status: :internal_server_error
    # end

    def render_bad_request(message)
      render json: { errors: "Invalid #{message}" }, status: :bad_request
    end

    def render_conflict(message)
      render json: { errors: message }, status: :conflict
    end

    def render_forbidden(message)
      render json: { errors: message }, status: :forbidden
    end

    def render_no_content
      render json: {}, status: :no_content
    end

    # テストしない
    def render_not_created(message)
      render json: { errors: "#{message} could not be created" }, status: :unprocessable_entity
    end

    # テストしない
    def render_not_destroyed(message)
      render json: { errors: "#{message} could not be destroyed" }, status: :unprocessable_entity
    end

    def render_not_found(message)
      render json: { errors: "#{message} not found" }, status: :not_found
    end

    def render_unprocessable(message)
      render json: { errors: "#{message} not found" }, status: :unprocessable_entity
    end

    def render_unprocessable_entity(object)
      render json: { errors: object.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
