require 'rails_helper'

RSpec.describe "V1::SearchesControllers", type: :request do
  describe "GET /v1/searches_controllers" do
    it "works! (now write some real specs)" do
      get v1_searches_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
