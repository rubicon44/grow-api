# frozen_string_literal: true

require 'rails_helper'

# TODO: 認証エラーの際は、401を返す(following時になっていない。)
# todo: contextとitのテストケース文言を揃える

RSpec.describe V1::UsersController, type: :request do
  # TODO: ユーザーを最初にまとめるか、それぞれのテストケースで作成するか検討する。
  let!(:user1) { FactoryBot.create(:user, nickname: 'user1', username: 'user1', bio: 'user1') }
  let!(:user2) { FactoryBot.create(:user, nickname: 'user2', username: 'user2', bio: 'user2') }
  let!(:headers1) { { 'Authorization' => JsonWebToken.encode(user_email: user1.email) } }
  let!(:headers2) { { 'Authorization' => JsonWebToken.encode(user_email: user2.email) } }
  let!(:task1_by_user1) { FactoryBot.create(:task, title: 'task1_by_user1', user: user1) }
  let!(:task2_by_user1) { FactoryBot.create(:task, title: 'task2_by_user1', user: user1) }
  let!(:like_by_user1) { FactoryBot.create(:like, user_id: user1.id, task_id: task1_by_user1.id) }

  describe 'GET #show (not logged in)' do
    it 'returns 401' do
      get "/v1/#{user1.username}"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end

    it 'returns 401 error if the user does not exist' do
      get '/v1/nonexistent_user'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #show (logged in)' do
    context 'when user1 is the logged-in user' do
      it 'returns the user details' do
        get "/v1/#{user1.username}", headers: headers1
        expect(response).to have_http_status(200)

        user_data = JSON.parse(response.body)
        expect(user_data['nickname']).to eq('user1')
        expect(user_data['username']).to eq('user1')
        expect(user_data['bio']).to eq('user1')

        tasks = user_data['tasks']
        expect(tasks.length).to eq(2)
        expect(tasks[0]['title']).to eq('task2_by_user1')
        expect(tasks[1]['title']).to eq('task1_by_user1')

        liked_tasks = user_data['liked_tasks']
        expect(liked_tasks.length).to eq(1)
        expect(liked_tasks[0]['title']).to eq('task1_by_user1')
      end
    end

    context 'when user2 is the logged-in user' do
      it 'returns the user details' do
        get "/v1/#{user2.username}", headers: headers2
        expect(response).to have_http_status(200)

        user_data = JSON.parse(response.body)
        expect(user_data['nickname']).to eq('user2')
        expect(user_data['username']).to eq('user2')
        expect(user_data['bio']).to eq('user2')

        tasks = user_data['tasks']
        expect(tasks).to eq([])

        liked_tasks = user_data['liked_tasks']
        expect(liked_tasks).to eq([])
      end
    end

    context 'when the requested user does not exist' do
      it 'returns 404 error' do
        get '/v1/nonexistent_user', headers: headers1
        expect(response).to have_http_status(404)
        expect(response.body).to eq('{"errors":"User not found"}')
      end
    end
  end

  describe 'GET #followings (not logged in)' do
    let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
    it 'returns 401' do
      get "/v1/#{user1.username}/followings"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end

    it 'returns 401 error if the user does not exist' do
      get '/v1/nonexistent_user/followings'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #followings (logged in)' do
    context 'when user has followings' do
      let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
      context 'when user1 is the logged-in user' do
        it 'returns the user\'s followings' do
          get "/v1/#{user1.username}/followings", headers: headers1
          expect(response).to have_http_status(200)

          followings_data = JSON.parse(response.body)['followings']
          expect(followings_data.length).to eq(1)
          expect(followings_data[0]['username']).to eq('user2')
        end
      end

      context 'when user2 is the logged-in user' do
        it 'returns the user\'s followings' do
          get "/v1/#{user2.username}/followings", headers: headers2
          expect(response).to have_http_status(200)

          followings_data = JSON.parse(response.body)['followings']
          expect(followings_data).to eq([])
        end
      end
    end

    context 'when user has no followings' do
      let!(:user) { FactoryBot.create(:user, username: 'user') }
      let!(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
      it 'returns 200 with an empty array' do
        get "/v1/#{user.username}/followings", headers: headers
        expect(response).to have_http_status(200)

        followings_data = JSON.parse(response.body)['followings']
        expect(followings_data).to be_empty
      end
    end

    context 'when attempting to get followings of a non-existing user' do
      it 'returns 404 error' do
        get '/v1/non_existing_user/followings', headers: headers1
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET #followers (not logged in)' do
    let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
    it 'returns 401' do
      get "/v1/#{user1.username}/followers"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end

    it 'returns 401 error if the user does not exist' do
      get '/v1/nonexistent_user/followers'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #followers (logged in)' do
    context 'when user has followers' do
      let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
      context 'when user1 is the logged-in user' do
        it 'returns the user\'s followers' do
          get "/v1/#{user2.username}/followers", headers: headers2
          expect(response).to have_http_status(200)

          followers_data = JSON.parse(response.body)['followers']
          expect(followers_data.length).to eq(1)
          expect(followers_data[0]['username']).to eq('user1')
        end
      end

      context 'when user2 is the logged-in user' do
        it 'returns the user\'s followers' do
          get "/v1/#{user1.username}/followers", headers: headers1
          expect(response).to have_http_status(200)

          followers_data = JSON.parse(response.body)['followers']
          expect(followers_data).to eq([])
        end
      end
    end

    context 'when user has no followers' do
      let!(:user) { FactoryBot.create(:user, username: 'user') }
      let!(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
      it 'returns 200 with an empty array' do
        get "/v1/#{user.username}/followers", headers: headers
        expect(response).to have_http_status(200)

        followers_data = JSON.parse(response.body)['followers']
        expect(followers_data).to be_empty
      end
    end

    context 'when attempting to get followers of a non-existing user' do
      it 'returns 404 error' do
        get '/v1/non_existing_user/followers', headers: headers1
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create' do
    it 'creates a new user' do
      user_params = {
        user: {
          nickname: 'John',
          username: 'john123',
          email: 'john@example.com',
          firebase_id: 'firebase123'
        }
      }

      # user作成時のみheader認証は省略。
      post '/v1/users', params: user_params
      expect(response).to have_http_status(204)

      user = User.last
      expect(user.nickname).to eq('John')
      expect(user.username).to eq('john123')
      expect(user.email).to eq('john@example.com')
      expect(user.firebase_id).to eq('firebase123')
    end

    context 'with invalid params' do
      it 'if nickname is missing' do
        user_params = {
          user: {
            nickname: nil,
            username: 'john123',
            email: 'john@example.com',
            firebase_id: 'firebase123'
          }
        }

        post '/v1/users', params: user_params
        expect(response).to have_http_status(422)
      end

      it 'if username is missing' do
        user_params = {
          user: {
            username: nil,
            nickname: 'John',
            email: 'john@example.com',
            firebase_id: 'firebase123'
          }
        }

        post '/v1/users', params: user_params
        expect(response).to have_http_status(422)
      end

      it 'if email is missing' do
        user_params = {
          user: {
            nickname: 'John',
            username: 'john123',
            email: nil,
            firebase_id: 'firebase123'
          }
        }

        post '/v1/users', params: user_params
        expect(response).to have_http_status(422)
      end

      it 'if firebase_id is missing' do
        user_params = {
          user: {
            nickname: 'John',
            username: 'john123',
            email: 'john@example.com',
            firebase_id: nil
          }
        }

        post '/v1/users', params: user_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT #update (not logged in)' do
    let!(:user3) { FactoryBot.create(:user) }
    let!(:headers3) { { 'Authorization' => JsonWebToken.encode(user_email: user3.email) } }
    it 'returns 401' do
      put "/v1/#{user3.username}"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end

    it 'returns 401 error if the user does not exist' do
      put '/v1/nonexistent_user'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'PUT #update (logged in)' do
    context 'when the user is the owner' do
      let!(:user4) { FactoryBot.create(:user) }
      let!(:headers4) { { 'Authorization' => JsonWebToken.encode(user_email: user4.email) } }
      it 'updates the user' do
        user_params = {
          user: {
            nickname: 'new_nickname',
            username: 'new_username',
            bio: 'new_bio'
          },
          current_user_id: user4.id
        }

        put "/v1/#{user4.username}", params: user_params, headers: headers4
        expect(response).to have_http_status(204)

        user4.reload
        expect(user4.nickname).to eq('new_nickname')
        expect(user4.username).to eq('new_username')
        expect(user4.bio).to eq('new_bio')
      end
    end

    context 'when the user is not the owner' do
      let!(:user5) { FactoryBot.create(:user, nickname: 'user5', username: 'user5', bio: 'user5') }
      let!(:user6) { FactoryBot.create(:user) }
      let!(:headers6) { { 'Authorization' => JsonWebToken.encode(user_email: user6.email) } }
      it 'returns forbidden status' do
        user_params = {
          user: {
            nickname: 'new_nickname',
            username: 'new_username',
            bio: 'new_bio'
          },
          current_user_id: user6.id
        }

        put "/v1/#{user5.username}", params: user_params, headers: headers6
        expect(response).to have_http_status(403)

        user5.reload
        expect(user5.nickname).to eq('user5')
        expect(user5.username).to eq('user5')
        expect(user5.bio).to eq('user5')
      end
    end

    context 'if the user does not exist' do
      it 'returns 404 error' do
        user_params = {
          user: {
            nickname: 'new_nickname',
            username: 'new_username',
            bio: 'new_bio'
          },
          current_user_id: user1.id
        }

        put '/v1/nonexistent_user', params: user_params, headers: headers1
        expect(response).to have_http_status(404)
        expect(response.body).to eq('{"errors":"User not found"}')
      end
    end
  end

  # TODO: describe 'GET #destroy (not logged in)' do
  # todo: describe 'GET #destroy (logged in)' do
end
