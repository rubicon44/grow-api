# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::SearchesController, type: :request do
  let!(:user1) { FactoryBot.create(:user, username: 'test1', nickname: 'test1') }
  let!(:user2) { FactoryBot.create(:user, username: 'test2', nickname: 'test2') }
  let!(:user3) { FactoryBot.create(:user, username: 'test3', nickname: 'test3') }
  let!(:user4) { FactoryBot.create(:user, username: 'test4', nickname: 'test4') }

  let!(:task1_by_user1) { FactoryBot.create(:task, title: 'task1_by_user1', content: 'task1_by_user1', user: user1) }
  let!(:task2_by_user1) { FactoryBot.create(:task, title: 'task2_by_user1', content: 'task2_by_user1', user: user1) }
  let!(:task3_by_user1) { FactoryBot.create(:task, title: 'task3_by_user1', content: 'task3_by_user1', user: user1) }
  let!(:task4_by_user1) { FactoryBot.create(:task, title: 'task4_by_user1', content: 'task4_by_user1', user: user1) }

  let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user1.email) } }
  let(:csrf_token) do
    get '/v1/csrf_token'
    JSON.parse(response.body)['csrf_token']['value']
  end
  let(:csrf_token_headers) { { 'X-CSRF-Token' => csrf_token } }
  let(:csrf_token_auth_headers) do
    auth_headers.merge('X-CSRF-Token' => csrf_token)
  end

  describe 'GET #index (logged in)' do
    context 'when searching for users (model: "user")' do
      it 'returns users with page: 1, page_size: 1 when contents are empty' do
        get '/v1/searches',
            params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['username']).to eq('test4')
      end

      it 'returns users with page: 2, page_size: 1 when contents are empty' do
        get '/v1/searches',
            params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 2, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['username']).to eq('test3')
      end

      it 'returns users when exceeding the number of registered users and contents are empty' do
        get '/v1/searches',
            params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 5, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        users_data = JSON.parse(response.body)
        expect(users_data).to eq([])
      end

      it 'returns users with page: 1, page_size: 2 when contents are empty' do
        get '/v1/searches',
            params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 1, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(2)
        expect(json_response[0]['username']).to eq('test4')
        expect(json_response[1]['username']).to eq('test3')
      end

      it 'returns users with page: 2, page_size: 2 when contents are empty' do
        get '/v1/searches',
            params: { model: 'user', contents: '', method: 'partial', data_type: 'users', page: 2, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(2)
        expect(json_response[0]['username']).to eq('test2')
        expect(json_response[1]['username']).to eq('test1')
      end

      it 'returns users that match the given contents with page_size: 1' do
        get '/v1/searches',
            params: { model: 'user', contents: '2', method: 'partial', data_type: 'users', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['username']).to eq('test2')
      end

      it 'returns users that match the given contents with page_size: 2' do
        get '/v1/searches',
            params: { model: 'user', contents: '2', method: 'partial', data_type: 'users', page: 1, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['username']).to eq('test2')
      end
    end

    context 'when searching for tasks (model: "task")' do
      it 'returns tasks with page: 1, page_size: 1 when contents are empty' do
        get '/v1/searches',
            params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['title']).to eq('task4_by_user1')
      end

      it 'returns tasks with page: 2, page_size: 1 when contents are empty' do
        get '/v1/searches',
            params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 2, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['title']).to eq('task3_by_user1')
      end

      it 'returns tasks when exceeding the number of registered tasks and contents are empty' do
        get '/v1/searches',
            params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 5, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        tasks_data = JSON.parse(response.body)
        expect(tasks_data).to eq([])
      end

      it 'returns tasks with page: 1, page_size: 2 when contents are empty' do
        get '/v1/searches',
            params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 1, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(2)
        expect(json_response[0]['title']).to eq('task4_by_user1')
        expect(json_response[1]['title']).to eq('task3_by_user1')
      end

      it 'returns tasks with page: 2, page_size: 2 when contents are empty' do
        get '/v1/searches',
            params: { model: 'task', contents: '', method: 'partial', data_type: 'tasks', page: 2, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(2)
        expect(json_response[0]['title']).to eq('task2_by_user1')
        expect(json_response[1]['title']).to eq('task1_by_user1')
      end

      it 'returns tasks that match the given contents with page_size: 1' do
        get '/v1/searches',
            params: { model: 'task', contents: '2', method: 'partial', data_type: 'tasks', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['title']).to eq('task2_by_user1')
      end

      it 'returns tasks that match the given contents with page_size: 2' do
        get '/v1/searches',
            params: { model: 'task', contents: '2', method: 'partial', data_type: 'tasks', page: 1, page_size: 2 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)

        json_response = JSON.parse(response.body)
        expect(json_response).not_to be_empty
        expect(json_response.count).to eq(1)
        expect(json_response[0]['title']).to eq('task2_by_user1')
      end
    end

    context 'when searching for users (model: not a "task" or "user")' do
      it 'returns empty array when contents are empty' do
        get '/v1/searches',
            params: { model: 'aaa', contents: '', method: 'partial', data_type: 'users', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(400)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Invalid search model')
      end

      it 'returns empty array when contents are given' do
        get '/v1/searches',
            params: { model: 'aaa', contents: '2', method: 'partial', data_type: 'users', page: 1, page_size: 1 },
            headers: csrf_token_auth_headers
        expect(response).to have_http_status(400)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Invalid search model')
      end
    end
  end
end
