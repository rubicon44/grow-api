# frozen_string_literal: true

class JsonWebToken
  SECRET_KEY = Rails.application.secrets.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now, alg = 'HS256')
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, alg)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: Settings.jwt.alg })[0]
    HashWithIndifferentAccess.new decoded
  end
end
