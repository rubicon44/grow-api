# require 'rails_helper'

# 「認証トークンが無効な場合のテストケース」を実装する(check_authenticate!)。

# RSpec.describe ApiController, type: :controller do
#   controller do
#     def index
#       check_authenticate!
#       render json: { message: "Authenticated" }, status: :ok
#     end
#   end

#   describe "authentication" do
#     context "when the token is missing" do
#       it "returns 401 Unauthorized" do
#         get :index
#         expect(response).to have_http_status(401)
#         expect(JSON.parse(response.body)).to eq({ "errors" => "Authorization token is missing" })
#       end
#     end

#     context "when the token is invalid" do
#       it "returns 401 Unauthorized" do
#         request.headers["Authorization"] = "invalid_token"
#         get :index
#         expect(response).to have_http_status(401)
#         expect(JSON.parse(response.body)).to eq({ "errors" => "Invalid token" })
#       end
#     end

#     context "when the token is valid" do
#       let(:user) { FactoryBot.create(:user) }
#       let(:token) { JsonWebToken.encode(user_email: user.email) }

#       it "returns 200 OK" do
#         request.headers["Authorization"] = token
#         get :index
#         expect(response).to have_http_status(200)
#         expect(JSON.parse(response.body)).to eq({ "message" => "Authenticated" })
#       end
#     end
#   end
# end