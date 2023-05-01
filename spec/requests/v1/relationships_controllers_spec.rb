require 'rails_helper'

RSpec.describe "V1::RelationshipsControllers", type: :request do
  describe "GET /v1/relationships_controllers" do
    it "works! (now write some real specs)" do
      get v1_relationships_controllers_path
      expect(response).to have_http_status(200)
    end
  end
end
