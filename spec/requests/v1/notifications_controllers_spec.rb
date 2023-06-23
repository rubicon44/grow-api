# frozen_string_literal: true

require 'rails_helper'

# 自分自身へのフォローはできない(別のspecでテスト済み)
RSpec.describe V1::NotificationsController, type: :request do
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

  let!(:auth_headers2) { { 'Authorization' => JsonWebToken.encode(user_email: user2.email) } }
  let(:csrf_token2) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers2) { { 'X-CSRF-Token' => csrf_token2 } }
  let(:csrf_token_auth_headers2) do
    auth_headers2.merge('X-CSRF-Token' => csrf_token2)
  end

  describe 'GET #index (not logged in)' do
    it 'returns 401' do
      get '/v1/notifications', params: { user_id: user2.id }, headers: csrf_token_headers2
      expect(response).to have_http_status(401)
      response_body = JSON.parse(response.body)
      expect(response_body['errors']).to include('Authorization token is missing')
    end
  end

  describe 'GET #index (logged in)' do
    context 'when retrieving notifications' do
      let!(:follow_notification) { FactoryBot.create(:notification, visitor: user1, visited: user2, action: 'follow') }
      let!(:like_notification) { FactoryBot.create(:notification, visitor: user1, visited: user2, action: 'like') }

      it 'returns the correct response' do
        get '/v1/notifications', params: { user_id: user2.id }, headers: csrf_token_auth_headers2
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['follow_visitors'].count).to eq(1)
        expect(json_response['like_visitors'].count).to eq(1)
        expect(json_response['notifications'].count).to eq(2)
        expect(json_response['follow_visitors'].map { |user| user['username'] }).to include('user1')
        expect(json_response['like_visitors'].map { |user| user['username'] }).to include('user1')
        expect(json_response['notifications'].map do |notification|
                 notification['id']
               end).to include(like_notification.id)
        expect(json_response['notifications'].map do |notification|
                 notification['id']
               end).to include(follow_notification.id)
      end
    end

    # TODO: [未実装]既読/未読機能
    # # 未読の通知が正しく既読に更新されることを確認するテストケース
    # context 'when marking unread notifications as read' do
    #   it 'marks unread notifications as read' do
    #   end
    # end
    # # 自分自身に送ったいいね通知は、既読済みとする(checked: true)

    context 'when excluding notifications(like) sent by the user' do
      let!(:like_notification) { FactoryBot.create(:notification, visitor: user1, visited: user2, action: 'like') }
      it 'excludes self-sent notifications' do
        get '/v1/notifications', params: { user_id: user1.id }, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['like_visitors'].count).to eq(0)
        expect(json_response['notifications'].count).to eq(0)
        expect(json_response['follow_visitors'].map { |user| user['username'] }).not_to include('user1')
        expect(json_response['notifications'].map do |notification|
                 notification['id']
               end).not_to include(like_notification.id)
      end
    end

    context 'when excluding notifications(like) sent by the user' do
      let!(:task) { FactoryBot.create(:task, title: 'task_by_task_created_user', user: user2) }
      it 'excludes sent notifications' do
        post "/v1/tasks/#{task.id}/likes", params: { current_user_id: user1.id, task_id: task.id },
                                           headers: csrf_token_auth_headers1
        expect(response).to have_http_status(204)

        post "/v1/tasks/#{task.id}/likes", params: { current_user_id: user1.id, task_id: task.id },
                                           headers: csrf_token_auth_headers1
        expect(response).to have_http_status(409)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to eq('User has already liked this task')

        get '/v1/notifications', params: { user_id: user2.id }, headers: csrf_token_auth_headers2
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['like_visitors'].count).to eq(1)
        expect(json_response['notifications'].count).to eq(1)
        expect(json_response['like_visitors'].map { |user| user['username'] }).to include('user1')
      end
    end

    context 'when excluding notifications(follow) sent by the user' do
      it 'excludes self-sent notifications' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(204)

        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers1
        expect(response).to have_http_status(409)

        get '/v1/notifications', params: { user_id: user2.id }, headers: csrf_token_auth_headers2
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response['follow_visitors'].count).to eq(1)
        expect(json_response['notifications'].count).to eq(1)
        expect(json_response['follow_visitors'].map { |user| user['username'] }).to include('user1')
      end
    end

    # TODO: [未実装]ページネーション機能
  end
end
