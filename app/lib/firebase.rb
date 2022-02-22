class Firebase
  def self.get_user_by_token(token)
    RestClient.post("https://www.googleapis.com/identitytoolkit/v3/relyingparty/getAccountInfo?key=#{ENV['FIREBASE_CONFIG_API_KEY']}", { idToken: token }.to_json,
      { 'Content-Type' => 'application/json' }) { |response, request, result|
      return response
    }
  end
end