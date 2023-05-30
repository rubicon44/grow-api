# frozen_string_literal: true

require 'rails_helper'

# 自分自身に対するいいねができることのテストは省略
# create, delete時にtask_idがparamsとして渡されていない場合のテストは、Railsの挙動により必要なし

RSpec.describe V1::LikesController, type: :request do
  let!(:task_created_user) { FactoryBot.create(:user, username: 'created_user') }
  let!(:current_user) { FactoryBot.create(:user, username: 'current_user') }
  let!(:other_user) { FactoryBot.create(:user, username: 'other_user') }
  let!(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: current_user.email) } }
  let!(:task) { FactoryBot.create(:task, title: 'task_by_task_created_user', user: task_created_user) }

  describe 'GET #index (not logged in)' do
    let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
    it 'returns 401' do
      get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #index (logged in)' do
    let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
    context 'when there are likes' do
      it 'returns a list of likes and like count' do
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: headers
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
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: headers
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
        get "/v1/tasks/#{task.id}/likes", params: { task_id: task.id }, headers: headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end
  end

  describe 'POST #create (not logged in)' do
    it 'returns 401' do
      post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id }
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'POST #create (logged in)' do
    context 'with valid params' do
      it 'creates a like and returns 204 status' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: headers
        expect(response).to have_http_status(204)

        expect(Like.count).to eq(1)
        expect(Like.last.task_id).to eq(task.id)
        expect(Like.last.user_id).to eq(current_user.id)
      end
    end

    context 'with invalid params' do
      it 'returns 422 if current_user_id is missing' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: nil }, headers: headers
        expect(response).to have_http_status(422)
      end
    end

    context 'when the same user likes the same task' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'returns 409 if the user has already liked the task' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: headers
        expect(response).to have_http_status(409)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Conflict: User has already liked this task')
      end
    end

    context 'when the task does not exist' do
      before do
        Task.destroy_all
      end
      it 'returns 404 if tasks do not exist' do
        post "/v1/tasks/#{task.id}/likes", params: { task_id: task.id, current_user_id: current_user.id },
                                           headers: headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end
  end

  describe 'DELETE #destroy (not logged in)' do
    let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
    let(:like_task_id) { like.task_id }
    let(:like_user_id) { like.user_id }
    it 'returns 401' do
      delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: current_user.id }
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'DELETE #destroy (logged in)' do
    context 'with valid params' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'removes the like and returns 204 status' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: current_user.id },
                                                        headers: headers
        expect(response).to have_http_status(204)
        expect(Like.count).to eq(0)
      end
    end

    context 'with invalid params' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      it 'returns 422 if current_user_id is missing' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: nil },
                                                        headers: headers
        expect(response).to have_http_status(422)
      end
    end

    context 'when trying to delete non-existent likes' do
      before do
        Like.destroy_all
      end
      it 'returns 404 if the likes does not exist' do
        delete "/v1/tasks/#{task.id}/likes/999", params: { task_id: task.id, current_user_id: current_user.id },
                                                 headers: headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Likes not found')
      end
    end

    context 'when deleting likes for non-existent tasks' do
      let!(:like) { FactoryBot.create(:like, user_id: current_user.id, task_id: task.id) }
      before do
        Task.destroy_all
      end
      it 'returns 404 if tasks do not exist' do
        delete "/v1/tasks/#{task.id}/likes/#{like.id}", params: { task_id: task.id, current_user_id: current_user.id },
                                                        headers: headers
        expect(response).to have_http_status(404)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Task not found')
      end
    end

    context 'when trying to delete other user\'s likes' do
      let!(:other_like) { FactoryBot.create(:like, user_id: other_user.id, task_id: task.id) }
      it 'returns 403 if trying to delete other user\'s likes' do
        delete "/v1/tasks/#{task.id}/likes/#{other_like.id}",
               params: { task_id: task.id, current_user_id: current_user.id }, headers: headers
        expect(response).to have_http_status(403)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Cannot delete other user\'s likes')
      end
    end
  end
end
