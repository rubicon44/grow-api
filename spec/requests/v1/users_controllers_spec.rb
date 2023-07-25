# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::UsersController, type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:user1) { FactoryBot.create(:user, nickname: 'user1', username: 'user1', bio: 'user1') }
  let!(:user2) { FactoryBot.create(:user, nickname: 'user2', username: 'user2', bio: 'user2') }
  let!(:task1_by_user1) { FactoryBot.create(:task, title: 'task1_by_user1', user: user1) }
  let!(:task2_by_user1) { FactoryBot.create(:task, title: 'task2_by_user1', user: user1) }
  let!(:like1_by_user1) { FactoryBot.create(:like, user_id: user1.id, task_id: task1_by_user1.id) }
  let!(:like2_by_user1) { FactoryBot.create(:like, user_id: user1.id, task_id: task2_by_user1.id) }

  let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
  let!(:auth_headers1) { { 'Authorization' => JsonWebToken.encode(user_email: user1.email) } }
  let(:csrf_token1) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers1) { { 'X-CSRF-Token' => csrf_token1 } }
  let(:csrf_token_auth_headers1) do
    auth_headers1.merge('X-CSRF-Token' => csrf_token1)
  end

  let!(:auth_headers2) { { 'Authorization' => JsonWebToken.encode(user_email: user2.email) } }
  let(:csrf_token2) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers2) { { 'X-CSRF-Token' => csrf_token2 } }
  let(:csrf_token_auth_headers2) do
    auth_headers2.merge('X-CSRF-Token' => csrf_token2)
  end

  # describe 'GET #show (logged in)' do
  #   let!(:task3_by_user1) { FactoryBot.create(:task, title: 'task3_by_user1', user: user1) }
  #   let!(:task4_by_user1) { FactoryBot.create(:task, title: 'task4_by_user1', user: user1) }
  #   let!(:like3_by_user1) { FactoryBot.create(:like, user_id: user1.id, task_id: task3_by_user1.id) }
  #   let!(:like4_by_user1) { FactoryBot.create(:like, user_id: user1.id, task_id: task4_by_user1.id) }

  #   context 'when user1 is the logged-in user' do
  #     it 'returns the user details with page: 1, page_size: 1 (data_type: default)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'default', page: 1, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(1)
  #       expect(tasks[0]['title']).to eq('task4_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(1)
  #       expect(liked_tasks[0]['title']).to eq('task4_by_user1')
  #     end

  #     it 'returns the user details with page: 2, page_size: 1 (data_type: default)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'default', page: 2, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(1)
  #       expect(tasks[0]['title']).to eq('task3_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(1)
  #       expect(liked_tasks[0]['title']).to eq('task3_by_user1')
  #     end

  #     it 'returns empty tasks and liked_tasks when exceeding the number of registered tasks' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'default', page: 5, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks).to eq([])

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to eq([])
  #     end

  #     it 'returns the user details with page: 1, page_size: 2 (data_type: default)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'default', page: 1, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(2)
  #       expect(tasks[0]['title']).to eq('task4_by_user1')
  #       expect(tasks[1]['title']).to eq('task3_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(2)
  #       expect(liked_tasks[0]['title']).to eq('task4_by_user1')
  #       expect(liked_tasks[1]['title']).to eq('task3_by_user1')
  #     end

  #     it 'returns the user details with page: 2, page_size: 2 (data_type: default)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'default', page: 2, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(2)
  #       expect(tasks[0]['title']).to eq('task2_by_user1')
  #       expect(tasks[1]['title']).to eq('task1_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(2)
  #       expect(liked_tasks[0]['title']).to eq('task2_by_user1')
  #       expect(liked_tasks[1]['title']).to eq('task1_by_user1')
  #     end

  #     it 'returns the user details with page: 1, page_size: 1 (data_type: tasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'tasks', page: 1, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(1)
  #       expect(tasks[0]['title']).to eq('task4_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to be_nil
  #     end

  #     it 'returns the user details with page: 2, page_size: 1 (data_type: tasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'tasks', page: 2, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(1)
  #       expect(tasks[0]['title']).to eq('task3_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to be_nil
  #     end

  #     it 'returns the user details with page: 1, page_size: 2 (data_type: tasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'tasks', page: 1, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(2)
  #       expect(tasks[0]['title']).to eq('task4_by_user1')
  #       expect(tasks[1]['title']).to eq('task3_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to be_nil
  #     end

  #     it 'returns the user details with page: 2, page_size: 2 (data_type: tasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'tasks', page: 2, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks.length).to eq(2)
  #       expect(tasks[0]['title']).to eq('task2_by_user1')
  #       expect(tasks[1]['title']).to eq('task1_by_user1')

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to be_nil
  #     end

  #     it 'returns the user details with page: 1, page_size: 1 (data_type: likedTasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'likedTasks', page: 1, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks).to be_nil

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(1)
  #       expect(liked_tasks[0]['title']).to eq('task4_by_user1')
  #     end

  #     it 'returns the user details with page: 2, page_size: 1 (data_type: likedTasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'likedTasks', page: 2, page_size: 1 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks).to be_nil

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(1)
  #       expect(liked_tasks[0]['title']).to eq('task3_by_user1')
  #     end

  #     it 'returns the user details with page: 1, page_size: 2 (data_type: likedTasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'likedTasks', page: 1, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks).to be_nil

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(2)
  #       expect(liked_tasks[0]['title']).to eq('task4_by_user1')
  #       expect(liked_tasks[1]['title']).to eq('task3_by_user1')
  #     end

  #     it 'returns the user details with page: 2, page_size: 2 (data_type: likedTasks)' do
  #       get "/v1/#{user1.username}", headers: csrf_token_auth_headers1,
  #                                    params: { data_type: 'likedTasks', page: 2, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user1')
  #       expect(user_data['username']).to eq('user1')
  #       expect(user_data['bio']).to eq('user1')

  #       tasks = user_data['tasks']
  #       expect(tasks).to be_nil

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks.length).to eq(2)
  #       expect(liked_tasks[0]['title']).to eq('task2_by_user1')
  #       expect(liked_tasks[1]['title']).to eq('task1_by_user1')
  #     end
  #   end

  #   context 'when user2 is the logged-in user' do
  #     it 'returns the user details' do
  #       get "/v1/#{user2.username}", headers: csrf_token_auth_headers2,
  #                                    params: { data_type: 'default', page: 1, page_size: 2 }
  #       expect(response).to have_http_status(200)

  #       user_data = JSON.parse(response.body)
  #       expect(user_data['nickname']).to eq('user2')
  #       expect(user_data['username']).to eq('user2')
  #       expect(user_data['bio']).to eq('user2')

  #       tasks = user_data['tasks']
  #       expect(tasks).to eq([])

  #       liked_tasks = user_data['liked_tasks']
  #       expect(liked_tasks).to eq([])
  #     end
  #   end

  #   context 'when the requested user does not exist' do
  #     it 'returns 404 error' do
  #       get '/v1/nonexistent_user', headers: csrf_token_auth_headers1
  #       expect(response).to have_http_status(404)
  #       response_body = JSON.parse(response.body)
  #       expect(response_body['errors']).to include('User not found')
  #     end
  #   end
  # end

  # describe 'GET #followings (logged in)' do
  #   context 'when user has followings' do
  #     let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
  #     context 'when user1 is the logged-in user' do
  #       it 'returns the user\'s followings' do
  #         get "/v1/#{user1.username}/followings", headers: csrf_token_auth_headers1
  #         expect(response).to have_http_status(200)

  #         followings_data = JSON.parse(response.body)['followings']
  #         expect(followings_data.length).to eq(1)
  #         expect(followings_data[0]['username']).to eq('user2')
  #       end
  #     end

  #     context 'when user2 is the logged-in user' do
  #       it 'returns the user\'s followings' do
  #         get "/v1/#{user2.username}/followings", headers: csrf_token_auth_headers2
  #         expect(response).to have_http_status(200)

  #         followings_data = JSON.parse(response.body)['followings']
  #         expect(followings_data).to eq([])
  #       end
  #     end
  #   end

  #   context 'when user has no followings' do
  #     let!(:user) { FactoryBot.create(:user, username: 'user') }
  #     let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
  #     let(:csrf_token) do
  #       get '/v1/csrf_token'
  #       JSON.parse(response.body)['csrf_token']['value']
  #     end
  #     let(:csrf_token_headers) { { 'X-CSRF-Token' => csrf_token } }
  #     let(:csrf_token_auth_headers) do
  #       auth_headers.merge('X-CSRF-Token' => csrf_token)
  #     end

  #     it 'returns 200 with an empty array' do
  #       get "/v1/#{user.username}/followings", headers: csrf_token_auth_headers
  #       expect(response).to have_http_status(200)

  #       followings_data = JSON.parse(response.body)['followings']
  #       expect(followings_data).to be_empty
  #     end
  #   end

  #   context 'when attempting to get followings of a non-existing user' do
  #     it 'returns 404 error' do
  #       get '/v1/non_existing_user/followings', headers: csrf_token_auth_headers1
  #       expect(response).to have_http_status(404)
  #     end
  #   end
  # end

  # describe 'GET #followers (logged in)' do
  #   context 'when user has followers' do
  #     let!(:follow_relationship) { FactoryBot.create(:relationship, following: user1, follower: user2) }
  #     context 'when user1 is the logged-in user' do
  #       it 'returns the user\'s followers' do
  #         get "/v1/#{user2.username}/followers", headers: csrf_token_auth_headers2
  #         expect(response).to have_http_status(200)

  #         followers_data = JSON.parse(response.body)['followers']
  #         expect(followers_data.length).to eq(1)
  #         expect(followers_data[0]['username']).to eq('user1')
  #       end
  #     end

  #     context 'when user2 is the logged-in user' do
  #       it 'returns the user\'s followers' do
  #         get "/v1/#{user1.username}/followers", headers: csrf_token_auth_headers1
  #         expect(response).to have_http_status(200)

  #         followers_data = JSON.parse(response.body)['followers']
  #         expect(followers_data).to eq([])
  #       end
  #     end
  #   end

  #   context 'when user has no followers' do
  #     let!(:user) { FactoryBot.create(:user, username: 'user') }
  #     let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
  #     let(:csrf_token) do
  #       get '/v1/csrf_token'
  #       JSON.parse(response.body)['csrf_token']['value']
  #     end
  #     let(:csrf_token_headers) { { 'X-CSRF-Token' => csrf_token } }
  #     let(:csrf_token_auth_headers) do
  #       auth_headers.merge('X-CSRF-Token' => csrf_token)
  #     end

  #     it 'returns 200 with an empty array' do
  #       get "/v1/#{user.username}/followers", headers: csrf_token_auth_headers
  #       expect(response).to have_http_status(200)

  #       followers_data = JSON.parse(response.body)['followers']
  #       expect(followers_data).to be_empty
  #     end
  #   end

  #   context 'when attempting to get followers of a non-existing user' do
  #     it 'returns 404 error' do
  #       get '/v1/non_existing_user/followers', headers: csrf_token_auth_headers1
  #       expect(response).to have_http_status(404)
  #     end
  #   end
  # end

  # describe 'POST #create' do
  #   it 'creates a new user' do
  #     user_params = {
  #       user: {
  #         nickname: 'John',
  #         username: 'john123',
  #         email: 'john@example.com',
  #         firebase_id: 'firebase123'
  #       }
  #     }

  #     # user作成時のみheader認証は省略。
  #     post '/v1/users', params: user_params, headers: csrf_token_headers1
  #     expect(response).to have_http_status(204)

  #     user = User.last
  #     expect(user.nickname).to eq('John')
  #     expect(user.username).to eq('john123')
  #     expect(user.email).to eq('john@example.com')
  #     expect(user.firebase_id).to eq('firebase123')
  #   end

  #   it 'returns 404 with invalid CSRF token' do
  #     user_params = {
  #       user: {
  #         nickname: 'Maria',
  #         username: 'Maria123',
  #         email: 'maria@example.com',
  #         firebase_id: 'firebase123456'
  #       }
  #     }
  #     post '/v1/users', params: user_params

  #     expect(response).to have_http_status(422)
  #     response_body = JSON.parse(response.body)
  #     expect(response_body['errors']).to include('Invalid CSRF token')
  #   end

  #   context 'with invalid params' do
  #     it 'if nickname is missing' do
  #       user_params = {
  #         user: {
  #           nickname: nil,
  #           username: 'john123',
  #           email: 'john@example.com',
  #           firebase_id: 'firebase123'
  #         }
  #       }

  #       post '/v1/users', params: user_params, headers: csrf_token_headers1
  #       expect(response).to have_http_status(422)
  #       json_response = JSON.parse(response.body)
  #       expect(json_response['errors']).to eq('A part of param not found')
  #     end

  #     it 'if username is missing' do
  #       user_params = {
  #         user: {
  #           username: nil,
  #           nickname: 'John',
  #           email: 'john@example.com',
  #           firebase_id: 'firebase123'
  #         }
  #       }

  #       post '/v1/users', params: user_params, headers: csrf_token_headers1
  #       expect(response).to have_http_status(422)
  #       json_response = JSON.parse(response.body)
  #       expect(json_response['errors']).to eq('A part of param not found')
  #     end

  #     it 'if email is missing' do
  #       user_params = {
  #         user: {
  #           nickname: 'John',
  #           username: 'john123',
  #           email: nil,
  #           firebase_id: 'firebase123'
  #         }
  #       }

  #       post '/v1/users', params: user_params, headers: csrf_token_headers1
  #       expect(response).to have_http_status(422)
  #       json_response = JSON.parse(response.body)
  #       expect(json_response['errors']).to eq('A part of param not found')
  #     end

  #     it 'if firebase_id is missing' do
  #       user_params = {
  #         user: {
  #           nickname: 'John',
  #           username: 'john123',
  #           email: 'john@example.com',
  #           firebase_id: nil
  #         }
  #       }

  #       post '/v1/users', params: user_params, headers: csrf_token_headers1
  #       expect(response).to have_http_status(422)
  #       json_response = JSON.parse(response.body)
  #       expect(json_response['errors']).to eq('A part of param not found')
  #     end
  #   end
  # end

  # describe 'PUT #update (logged in)' do
  #   context 'when the user is the owner' do
  #     let!(:user4) { FactoryBot.create(:user) }
  #     let!(:auth_headers4) { { 'Authorization' => JsonWebToken.encode(user_email: user4.email) } }
  #     let(:csrf_token4) do
  #       get '/v1/csrf_token'
  #       JSON.parse(response.body)['csrf_token']['value']
  #     end
  #     let(:csrf_token_headers4) { { 'X-CSRF-Token' => csrf_token4 } }
  #     let(:csrf_token_auth_headers4) do
  #       auth_headers4.merge('X-CSRF-Token' => csrf_token4)
  #     end

  #     # 「context 'when the user is the owner' do」の外側へ移動
  #     it 'returns 404 with invalid CSRF token' do
  #       put "/v1/#{user4.username}", headers: auth_headers

  #       expect(response).to have_http_status(422)
  #       response_body = JSON.parse(response.body)
  #       expect(response_body['errors']).to include('Invalid CSRF token')
  #     end

  #     it 'updates the user' do
  #       user_params = {
  #         user: {
  #           nickname: 'new_nickname',
  #           username: 'new_username',
  #           bio: 'new_bio'
  #         },
  #         current_user_id: user4.id
  #       }

  #       put "/v1/#{user4.username}", params: user_params, headers: csrf_token_auth_headers4
  #       expect(response).to have_http_status(200)

  #       user4.reload
  #       expect(user4.nickname).to eq('new_nickname')
  #       expect(user4.username).to eq('new_username')
  #       expect(user4.bio).to eq('new_bio')
  #     end
  #   end

  #   context 'when the user is not the owner' do
  #     let!(:user5) { FactoryBot.create(:user, nickname: 'user5', username: 'user5', bio: 'user5') }
  #     let!(:user6) { FactoryBot.create(:user) }
  #     let!(:auth_headers6) { { 'Authorization' => JsonWebToken.encode(user_email: user6.email) } }
  #     let(:csrf_token6) do
  #       get '/v1/csrf_token'
  #       JSON.parse(response.body)['csrf_token']['value']
  #     end
  #     let(:csrf_token_headers6) { { 'X-CSRF-Token' => csrf_token6 } }
  #     let(:csrf_token_auth_headers6) do
  #       auth_headers6.merge('X-CSRF-Token' => csrf_token6)
  #     end

  #     it 'returns forbidden status' do
  #       user_params = {
  #         user: {
  #           nickname: 'new_nickname',
  #           username: 'new_username',
  #           bio: 'new_bio'
  #         },
  #         current_user_id: user6.id
  #       }

  #       put "/v1/#{user5.username}", params: user_params, headers: csrf_token_auth_headers6
  #       expect(response).to have_http_status(403)

  #       user5.reload
  #       expect(user5.nickname).to eq('user5')
  #       expect(user5.username).to eq('user5')
  #       expect(user5.bio).to eq('user5')
  #     end
  #   end

  #   context 'if the user does not exist' do
  #     it 'returns 404 error' do
  #       user_params = {
  #         user: {
  #           nickname: 'new_nickname',
  #           username: 'new_username',
  #           bio: 'new_bio'
  #         },
  #         current_user_id: user1.id
  #       }

  #       put '/v1/nonexistent_user', params: user_params, headers: csrf_token_auth_headers1
  #       expect(response).to have_http_status(404)
  #       response_body = JSON.parse(response.body)
  #       expect(response_body['errors']).to include('User not found')
  #     end
  #   end
  # end

  # TODO: describe 'GET #destroy (logged in)' do

  describe 'PUT #upload_avatar' do
    let!(:user7) { FactoryBot.create(:user) }
    let!(:auth_headers7) { { 'Authorization' => JsonWebToken.encode(user_email: user7.email) } }
    let(:csrf_token7) do
      get '/v1/csrf_token'
      JSON.parse(response.body)['csrf_token']['value']
    end
    let(:csrf_token_headers7) { { 'X-CSRF-Token' => csrf_token7 } }
    let(:csrf_token_auth_headers7) do
      auth_headers7.merge('X-CSRF-Token' => csrf_token7)
    end

    context 'when the avatar file is present' do
      let(:avatar_file) { fixture_file_upload('avatar_1.png', 'image/png') }

      it 'uploads the avatar file to AWS S3 and returns the avatar URL' do
        # S3Uploaderクラスとそのメソッドをスタブ化して、実際のS3アップロードを回避。
        allow(S3Uploader).to receive(:upload_avatar_url_to_s3).and_return('https://s3-bucket-for-user-avatar.s3.amazonaws.com/avatar_1.png')

        post "/v1/#{user7.username}/upload_avatar", headers: csrf_token_auth_headers7, params: { file: avatar_file }
        expect(response).to have_http_status(200)

        avatar_url = response.body
        expect(avatar_url).to match('https://s3-bucket-for-user-avatar.s3.amazonaws.com/avatar_1.png')
        user7.reload
        expect(user7.avatar_url).to eq(avatar_url)
      end
    end

    context 'when the avatar file is missing' do
      it 'returns a not found error' do
        post "/v1/#{user7.username}/upload_avatar", headers: csrf_token_auth_headers7
        expect(response).to have_http_status(404)
        expect(response.body).to match('avatar_file')
      end
    end

    context 'when the avatar file upload fails' do
      it 'returns an error message' do
        allow(S3Uploader).to receive(:upload_avatar_url_to_s3).and_raise(StandardError)

        avatar_file = fixture_file_upload('avatar_1.png', 'image/png')
        post "/v1/#{user7.username}/upload_avatar", headers: csrf_token_auth_headers7, params: { file: avatar_file }
        expect(response).to have_http_status(500)
        expect(response.body).to match('Internal Server Error')
      end
    end
  end
end
