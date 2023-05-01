require 'rails_helper'

RSpec.describe "V1::LikesControllers", type: :request do
  describe "GET /v1/likes_controllers" do
    it "works! (now write some real specs)" do
      get v1_likes_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
