# frozen_string_literal: true

require 'rails_helper'

# TODO1: usersの場合もテスト

RSpec.describe V1::SearchesController, type: :request do
  let!(:user) { FactoryBot.create(:user, username: 'test1') }
  let!(:task) { FactoryBot.create(:task, title: 'task1', user: user) }

  let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
  let(:csrf_token) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers) { { 'X-CSRF-Token' => csrf_token } }
  let(:csrf_token_auth_headers) do
    auth_headers.merge('X-CSRF-Token' => csrf_token)
  end

  describe 'GET #index (not logged in)' do
    it 'returns 401' do
      get '/v1/searches',
          params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 1, page_size: 2 },
          headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #index (logged in)' do
    context 'when searching for users (model: "user")' do
      context 'when method is "partial"' do
        it 'returns users when contents is empty' do
          get '/v1/searches',
              params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 1, page_size: 2 },
              headers: csrf_token_auth_headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response).not_to be_empty
          expect(json_response.count).to eq(1)
          expect(json_response[0]['username']).to eq('test1')
        end

        it 'returns users that match the given contents' do
          get '/v1/searches',
              params: { model: 'user', contents: 'test', method: 'partial', data_type: 'users', page: 1, page_size: 2 },
              headers: csrf_token_auth_headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response).not_to be_empty
          expect(json_response.count).to eq(1)
          expect(json_response[0]['username']).to eq('test1')
        end
      end
    end

    context 'when searching for tasks (model: "task")' do
      context 'when method is "partial"' do
        it 'returns tasks when contents is empty' do
          get '/v1/searches',
              params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 1, page_size: 2 },
              headers: csrf_token_auth_headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response).not_to be_empty
          expect(json_response.count).to eq(1)
          expect(json_response[0]['title']).to eq('task1')
        end

        it 'returns tasks that match the given contents' do
          get '/v1/searches',
              params: { model: 'task', contents: 'task', method: 'partial', data_type: 'tasks', page: 1, page_size: 2 },
              headers: csrf_token_auth_headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response).not_to be_empty
          expect(json_response.count).to eq(1)
          expect(json_response[0]['title']).to eq('task1')
        end
      end
    end
  end
end
