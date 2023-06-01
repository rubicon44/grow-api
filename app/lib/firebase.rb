# frozen_string_literal: true

class Firebase
  def self.get_user_by_token(token)
    RestClient.post(
      "https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=#{ENV['FIREBASE_CONFIG_API_KEY']}",
      { idToken: token }.to_json,
      { 'Content-Type' => 'application/json' }
    ) do |response, _request, _result|
      return response
    end
  end
end
