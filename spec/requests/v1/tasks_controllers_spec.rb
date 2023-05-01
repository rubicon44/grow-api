require 'rails_helper'

RSpec.describe V1::TasksController, type: :request do
  describe 'GET #index' do
    it 'returns http success' do
      get '/v1/tasks'
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    let(:task) { FactoryBot.create(:task) }

    it 'returns http success' do
      get "/v1/tasks/#{task.id}"
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    let(:user) { FactoryBot.create(:user) }
    let(:valid_params) { { task: FactoryBot.attributes_for(:task), user_id: user.firebase_id } }
    let(:invalid_params) { { task: { title: '' }, user_id: user.firebase_id } }

    context 'with valid params' do
      it 'creates a new task' do
        expect {
          post '/v1/tasks', params: valid_params
        }.to change(Task, :count).by(1)
      end

      it 'returns http created' do
        post '/v1/tasks', params: valid_params
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      it 'does not create a new task' do
        expect {
          post '/v1/tasks', params: invalid_params
        }.to_not change(Task, :count)
      end

      it 'returns http unprocessable_entity' do
        post '/v1/tasks', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    let(:task) { FactoryBot.create(:task) }
    let(:valid_params) { { task: { title: 'new title' } } }
    let(:invalid_params) { { task: { title: '' } } }

    context 'with valid params' do
      it 'updates the requested task' do
        patch "/v1/tasks/#{task.id}", params: valid_params
        task.reload
        expect(task.title).to eq('new title')
      end

      it 'returns http success' do
        patch "/v1/tasks/#{task.id}", params: valid_params
        expect(response).to have_http_status(201)
      end
    end

    context 'with invalid params' do
      it 'does not update the requested task' do
        patch "/v1/tasks/#{task.id}", params: invalid_params
        task.reload
        expect(task.title).to_not eq('')
      end

      it 'returns http unprocessable_entity' do
        patch "/v1/tasks/#{task.id}", params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:task) { FactoryBot.create(:task) }

    it 'destroys the requested task' do
      expect {
        delete "/v1/tasks/#{task.id}"
      }.to change(Task, :count).by(-1)
    end

    it 'returns http no_content' do
      delete "/v1/tasks/#{task.id}"
      expect(response).to have_http_status(204)
    end
  end
end