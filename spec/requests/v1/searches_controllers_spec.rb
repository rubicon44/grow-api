require 'rails_helper'

RSpec.describe V1::SearchesController, type: :request do
  let!(:user) { FactoryBot.create(:user, username: "test1") }
  let!(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }
  let!(:task) { FactoryBot.create(:task, title: 'task1', user: user) }

  describe 'GET #index (not logged in)' do
    it 'returns 401' do
      get '/v1/searches', params: { model: 'user', contents: '', method: 'partial' }
      expect(response).to have_http_status(401)
      expect(response.body).to eq("{\"errors\":\"Authorization token is missing\"}")
    end
  end

  describe 'GET #index (logged in)' do
    context 'when searching for users (model: "user")' do
      context 'when method is "partial"' do
        it 'returns users when contents is empty' do
          get '/v1/searches', params: { model: 'user', contents: '', method: 'partial' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['users']).not_to be_empty
          expect(json_response['users'].count).to eq(1)
          expect(json_response['users'][0]['username']).to eq('test1')
        end

        it 'returns users that match the given contents' do
          get '/v1/searches', params: { model: 'user', contents: 'test', method: 'partial' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['users']).not_to be_empty
          expect(json_response['users'].count).to eq(1)
          expect(json_response['users'][0]['username']).to eq('test1')
        end
      end

      context 'when method is "perfect"' do
        it 'returns users when contents is empty' do
          get '/v1/searches', params: { model: 'user', contents: '', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['users']).to be_empty.or be_nil
        end

        it 'returns users that exactly match the given contents' do
          get '/v1/searches', params: { model: 'user', contents: 'test1', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['users']).not_to be_empty
          expect(json_response['users'].count).to eq(1)
          expect(json_response['users'][0]['username']).to eq('test1')
        end

        it 'returns no users when contents contain a string that does not have an exact match' do
          get '/v1/searches', params: { model: 'user', contents: 'test', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['users']).to be_empty.or be_nil
        end
      end
    end

    context 'when searching for tasks (model: "task")' do
      context 'when method is "partial"' do
        it 'returns tasks when contents is empty' do
          get '/v1/searches', params: { model: 'task', contents: '', method: 'partial' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['tasks']).not_to be_empty
          expect(json_response['tasks'].count).to eq(1)
          expect(json_response['tasks'][0]['title']).to eq('task1')
        end

        it 'returns tasks that match the given contents' do
          get '/v1/searches', params: { model: 'task', contents: 'task', method: 'partial' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['tasks']).not_to be_empty
          expect(json_response['tasks'].count).to eq(1)
          expect(json_response['tasks'][0]['title']).to eq('task1')
        end
      end

      context 'when method is "perfect"' do
        it 'returns tasks when contents is empty' do
          get '/v1/searches', params: { model: 'task', contents: '', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['tasks']).to be_empty.or be_nil
        end

        it 'returns tasks that exactly match the given contents' do
          get '/v1/searches', params: { model: 'task', contents: 'task1', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['tasks']).not_to be_empty
          expect(json_response['tasks'].count).to eq(1)
          expect(json_response['tasks'][0]['title']).to eq('task1')
        end

        it 'returns no tasks when contents contain a string that does not have an exact match' do
          get '/v1/searches', params: { model: 'task', contents: 'task', method: 'perfect' }, headers: headers
          expect(response).to have_http_status(200)

          json_response = JSON.parse(response.body)
          expect(json_response['tasks']).to be_empty.or be_nil
        end
      end
    end
  end
end