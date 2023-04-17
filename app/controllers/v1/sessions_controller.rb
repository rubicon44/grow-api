module V1
  class SessionsController < ApiController
    skip_before_action :check_authenticate!, only: %i(create), raise: false

    def create
      token = request.headers["idToken"]
      respon = Firebase.get_user_by_token(token)
      response = JSON.parse(respon)

      case respon.code
      when 301, 302, 307, 400, 500
        return render json: { error: response["error"]["errors"] }, status: respon.code
      when 200
        info = response["users"].last
        email = info["email"] rescue nil

        if email != nil
          @user = User.find_by(email: email)
          return render json: { error: "このメールアドレスが見つかりません。" }, status: 422 if @user.blank?
          @user.update(firebase_id: info["localId"])
          time = Time.now + 24.hours.to_i
          token = JsonWebToken.encode({user_email: @user.email}, Settings.jwt.time_exp.hours.from_now, Settings.jwt.alg)
          render json: {token: token, user: @user.attributes.except("password_digest"), exp: time.strftime("%m-%d-%Y %H:%M")}, status: :ok
        end
      end
    end
  end
end