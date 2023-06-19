# frozen_string_literal: true

module V1
  class SessionsController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false

    def create
      token = request.headers['Authorization']
      respon = Firebase.get_user_by_token(token)
      response = JSON.parse(respon)

      case respon.code
      when 301, 302, 307, 400, 500
        handle_error(response, respon.code)
      when 200
        process_successful_response(response)
      end
    end

    private

    def handle_error(response, code)
      errors = response['error']['errors']
      render json: { error: errors }, status: code
    end

    def process_successful_response(response)
      info = response['users'].last
      email = info['email']

      if email.nil?
        render json: { error: 'このメールアドレスが見つかりません。' }, status: :unprocessable_entity
      else
        user = User.find_by(email: email)
        handle_user(user, info) if user.present?
      end
    end

    def handle_user(user, info)
      user.update(firebase_id: info['localId'])
      time = Time.zone.now + 24.hours.to_i
      token = generate_token(user)
      user_attributes = user.attributes.except('password_digest')

      render json: {
        token: token,
        user: user_attributes,
        exp: time.strftime('%m-%d-%Y %H:%M')
      }, status: :ok
    end

    def generate_token(user)
      JsonWebToken.encode({ user_email: user.email }, Settings.jwt.time_exp.hours.from_now, Settings.jwt.alg)
    end
  end
end
