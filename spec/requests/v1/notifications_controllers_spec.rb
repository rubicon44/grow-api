require 'rails_helper'

RSpec.describe "V1::NotificationsControllers", type: :request do
  describe "GET /v1/notifications_controllers" do
    it "works! (now write some real specs)" do
      get v1_notifications_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
