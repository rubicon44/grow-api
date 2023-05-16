module V1
  class ApiController < ApplicationController
    before_action :check_authenticate!
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordInvalid, with: :render_422
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::BadRequest, with: :render_400

    private

    def check_authenticate!
      token = request.cookies['token']
      csrf_token = request.headers['X-CSRF-Token']

      # render json: { errors: {
      #   "csrf_token": csrf_token,
      #   "cookies['X-CSRF-Token']": cookies['X-CSRF-Token']
      #   } }
      # return

      if token.blank?
        render json: { errors: "Authorization token is missing" }, status: :unauthorized
        return
      end
      begin
        decoded = JsonWebToken.decode(token)
        current_user = User.find_by(email: decoded[:user_email])

        origin_csrf_token = cookies['X-CSRF-Token']
        unless csrf_token == origin_csrf_token
          render json: {
            errors: "Invalid CSRF token",
            # "csrf_token": "#{csrf_token}",
            # "origin_csrf_token": "#{origin_csrf_token}"
            }, status: 401
          return
        end

        return current_user
      rescue ActiveRecord::RecordNotFound => e
        render json: { errors: e.message }, status: :unauthorized
      rescue JWT::DecodeError => e
        render json: { errors: e.message }, status: :unauthorized
      end
    end

    def render_500(errors)
      logger.error(errors) # 例外をログに出力
      render json: { errors: 'Internal Server Error' }, status: 500
    end

    def render_422(errors)
      render json: { errors: errors }, status: 422
    end

    def render_404(errors)
      render json: { errors: errors }, status: 404
    end

    def render_400(errors)
      render json: { errors: errors }, status: 400
    end
  end
end