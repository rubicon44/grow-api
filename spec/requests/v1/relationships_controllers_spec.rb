# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::RelationshipsController, type: :request do
  let!(:user1) { FactoryBot.create(:user, nickname: 'user1', username: 'user1', bio: 'user1') }
  let!(:user2) { FactoryBot.create(:user, nickname: 'user2', username: 'user2', bio: 'user2') }

  let!(:auth_headers1) { { 'Authorization' => JsonWebToken.encode(user_email: user1.email) } }
  let(:csrf_token1) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers1) { { 'X-CSRF-Token' => csrf_token1 } }
  let(:csrf_token_auth_headers1) do
    auth_headers1.merge('X-CSRF-Token' => csrf_token1)
  end

  describe 'POST #create (not logged in)' do
    it 'returns 401' do
      params = { following_id: user1.id, follower_id: user2.id }
      post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_headers1
      expect(response).to have_http_status(401)
      response_body = JSON.parse(response.body)
      expect(response_body['errors']).to include('Authorization token is missing')
    end

    it 'returns 401 error if the user does not exist' do
      params = { following_id: user1.id, follower_id: user2.id }
      post '/v1/users/nonexistent_user_id/relationships', params: params, headers: csrf_token_headers1
      expect(response).to have_http_status(401)
      response_body = JSON.parse(response.body)
      expect(response_body['errors']).to include('Authorization token is missing')
    end
  end

  describe 'POST #create (logged in)' do
    context 'when following a user' do
      it 'follows the user' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(204)
        expect(user1.followings).to include(user2)
        expect(user2.followers).to include(user1)
      end
    end

    context 'when retrieving follower list' do
      let!(:user3) { FactoryBot.create(:user, nickname: 'user3', username: 'user3', bio: 'user3') }
      let!(:follow_relationship1) { FactoryBot.create(:relationship, following: user2, follower: user1) }
      let!(:follow_relationship2) { FactoryBot.create(:relationship, following: user3, follower: user1) }
      it 'returns the follower list in the correct order' do
        get "/v1/#{user1.username}/followers", headers: csrf_token_auth_headers1
        expect(response).to have_http_status(200)

        follower_list = JSON.parse(response.body)['followers']
        follower_usernames = follower_list.map { |follower| follower['username'] }
        expect(follower_usernames).to eq([user3.username, user2.username])
      end
    end

    context 'when retrieving following list' do
      let!(:user3) { FactoryBot.create(:user, nickname: 'user3', username: 'user3', bio: 'user3') }
      let!(:follow_relationship1) { FactoryBot.create(:relationship, following: user1, follower: user2) }
      let!(:follow_relationship2) { FactoryBot.create(:relationship, following: user1, follower: user3) }
      it 'returns the following list in the correct order' do
        get "/v1/#{user1.username}/followings", headers: csrf_token_auth_headers1
        expect(response).to have_http_status(200)

        following_list = JSON.parse(response.body)['followings']
        following_usernames = following_list.map { |following| following['username'] }
        expect(following_usernames).to eq([user3.username, user2.username])
      end
    end

    context 'when attempting to follow self' do
      it 'does not allow following self' do
        params = { following_id: user1.id, follower_id: user1.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq('You cannot follow yourself.')
      end
    end

    context 'when attempting to follow the same user multiple times' do
      let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
      it 'does not allow following the same user multiple times' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(409)
        expect(JSON.parse(response.body)['errors']).to eq('Already following this user.')
      end
    end

    context 'when attempting to follow a non-existing user' do
      it 'does not allow following a non-existing user (follower_id)' do
        params = { following_id: user1.id, follower_id: 0 }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=#{params[:follower_id]}")
      end

      it 'does not allow following a non-existing user (following_id)' do
        params = { following_id: 0, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=#{params[:following_id]}")
      end
    end
  end

  describe 'DELETE #destroy (not logged in)' do
    let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
    it 'returns 401' do
      params = { following_id: user1.id, follower_id: user2.id }
      delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_headers1
      expect(response).to have_http_status(401)
      response_body = JSON.parse(response.body)
      expect(response_body['errors']).to include('Authorization token is missing')
    end

    it 'returns 401 error if the user does not exist' do
      params = { following_id: user1.id, follower_id: user2.id }
      delete '/v1/users/nonexistent_user_id/relationships', params: params, headers: csrf_token_headers1
      expect(response).to have_http_status(401)
      response_body = JSON.parse(response.body)
      expect(response_body['errors']).to include('Authorization token is missing')
    end
  end

  describe 'DELETE #destroy (logged in)' do
    context 'when unfollowing a previously followed user' do
      let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
      it 'unfollows the user' do
        params = { following_id: user1.id, follower_id: user2.id }
        delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(204)
        expect(user1.followings).not_to include(user2)
        expect(user2.followers).not_to include(user1)
      end
    end

    context 'when attempting to unfollow self' do
      it 'does not allow unfollowing self' do
        params = { following_id: user1.id, follower_id: user1.id }
        delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['errors']).to eq('You cannot unfollow yourself.')
      end
    end

    context 'when attempting to unfollow the same user multiple times' do
      it 'does not allow unfollowing the same user multiple times' do
        params = { following_id: user1.id, follower_id: user2.id }
        delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(409)
        expect(JSON.parse(response.body)['errors']).to eq('Not unfollowing this user.')
      end
    end

    context 'when attempting to follow a non-existing user' do
      it 'does not allow unfollowing a non-existing user (follower_id)' do
        params = { following_id: user1.id, follower_id: 0 }
        delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=#{params[:follower_id]}")
      end

      it 'does not allow unfollowing a non-existing user (following_id)' do
        params = { following_id: 0, follower_id: user2.id }
        delete "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['errors']).to eq("Couldn't find User with 'id'=#{params[:following_id]}")
      end
    end
  end
end
