# frozen_string_literal: true

require 'rails_helper'

# 自分自身に対するいいねができることのテストは省略
# create, delete時にtask_idがparamsとして渡されていない場合のテストは、Railsの挙動により必要なし
RSpec.describe V1::LikesController, type: :request do
  let!(:task_created_user) { FactoryBot.create(:user, username: 'created_user') }
  let!(:current_user) { FactoryBot.create(:user, username: 'current_user') }
  let!(:other_user) { FactoryBot.create(:user, username: 'other_user') }
  let!(:task) { FactoryBot.create(:task, title: 'task_by_task_created_user', user: task_created_user) }

  let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: current_user.email) } }
  let(:csrf_token) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers) { { 'X-CSRF-Token' => csrf_token } }
  let(:csrf_token_auth_headers) do
    auth_headers.merge('X-CSRF-Token' => csrf_token)
  end

  describe 'GET #index (logged in)' do
    let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
    context 'when there are likes' do
      it 'returns a list of likes and like count' do
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['likes']).to be_an(Array)
        expect(json_response['like_count']).to eq(1)
      end
    end

    context 'when there are no likes' do
      before do
        like.destroy
      end
      it 'returns an empty list of likes and like count when there are no likes' do
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['likes']).to be_an(Array)
        expect(json_response['likes']).to be_empty
        expect(json_response['like_count']).to eq(0)
      end
    end

    context 'when the task does not exist' do
      before do
        Task.destroy_all
      end
      it 'returns 404 if tasks do not exist' do
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Task not found')
      end
    end
  end

  describe 'POST #create (logged in)' do
    context 'with valid params' do
      it 'creates a like and returns 204 status' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)

        expect(Like.count).to eq(1)
        expect(Like.last.task_id).to eq(task.id)
        expect(Like.last.user_id).to eq(current_user.id)
      end
    end

    context 'with invalid params' do
      it 'returns 422 if current_user_id is missing' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: nil },
                                           headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Current User not found')
      end
    end

    context 'when the same user likes the same task' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'returns 409 if the user has already liked the task' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: csrf_token_auth_headers
        expect(response).to have_http_status(409)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('User has already liked this task')
      end
    end

    context 'when the task does not exist' do
      before do
        Task.destroy_all
      end
      it 'returns 404 if tasks do not exist' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Task not found')
      end
    end
  end

  describe 'DELETE #destroy (logged in)' do
    context 'with valid params' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'removes the like and returns 204 status' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: current_user.id },
                                                        headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Like.count).to eq(0)
      end
    end

    context 'with invalid params' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'returns 422 if current_user_id is missing' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: nil },
                                                        headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Current User not found')
      end
    end

    context 'when trying to delete non-existent likes' do
      before do
        Like.destroy_all
      end
      it 'returns 404 if the likes does not exist' do
        delete "/v1/tasks/#{task.id}/likes/0", params: { task_id: task.id, current_user_id: current_user.id },
                                               headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Likes not found')
      end
    end

    context 'when deleting likes for non-existent tasks' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      before do
        Task.destroy_all
      end
      it 'returns 404 if tasks do not exist' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: current_user.id },
                                                        headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Task not found')
      end
    end

    context 'when trying to delete other user\'s likes' do
      let!(:other_like) { FactoryBot.create(:like, user_id: other_user.id, task_id: task.id) }
      it 'returns 403 if trying to delete other user\'s likes' do
        delete "/v1/tasks/#{task.id}/likes/#{other_like.id}",
               params: { task_id: task.id, current_user_id: current_user.id }, headers: csrf_token_auth_headers
        expect(response).to have_http_status(403)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('Cannot delete other user\'s likes')
      end
    end
  end
end
