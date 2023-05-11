require 'rails_helper'

RSpec.describe V1::TasksController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:task) { FactoryBot.create(:task, user: user) }
  # todo: 「JsonWebToken.encode(user_id: user.id)」で通ってしまうが、適切か確認。
  let(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }

  describe 'GET #index' do
    it 'returns http success' do
      get '/v1/tasks', headers: headers
      expect(response).to have_http_status(200)
    end
  end

  # describe 'GET #show' do
  #   it 'returns http success' do
  #     get "/v1/tasks/#{task.id}", headers: headers
  #     expect(response).to have_http_status(200)
  #   end
  # end

  describe 'POST #create' do
    let!(:valid_params) { { task: FactoryBot.create(:task, user_id: user.id).attributes } }
    context 'with valid params' do
      it 'creates a new task' do
        expect {
          post '/v1/tasks', params: valid_params, headers: headers
        }.to change(user.tasks, :count).by(1)
        task = Task.last
        expect(task.user_id).to eq(user.id)
      end

      # it 'returns http created' do
      #   post '/v1/tasks', params: valid_params, headers: headers
      #   expect(response).to have_http_status(204)
      # end
    end

    # context 'with invalid params' do
    #   it 'does not create a new task' do
    #     expect {
    #       post '/v1/tasks', params: invalid_params
    #     }.to_not change(Task, :count)
    #   end

    #   it 'returns http unprocessable_entity' do
    #     post '/v1/tasks', params: invalid_params
    #     expect(response).to have_http_status(:unprocessable_entity)
    #   end
    # end
  end

  # describe 'PATCH #update' do
  #   let(:task) { FactoryBot.create(:task) }
  #   let(:valid_params) { { task: { title: 'new title' } } }
  #   let(:invalid_params) { { task: { title: '' } } }

  #   context 'with valid params' do
  #     it 'updates the requested task' do
  #       patch "/v1/tasks/#{task.id}", params: valid_params
  #       task.reload
  #       expect(task.title).to eq('new title')
  #     end

  #     it 'returns http success' do
  #       patch "/v1/tasks/#{task.id}", params: valid_params
  #       expect(response).to have_http_status(201)
  #     end
  #   end

  #   context 'with invalid params' do
  #     it 'does not update the requested task' do
  #       patch "/v1/tasks/#{task.id}", params: invalid_params
  #       task.reload
  #       expect(task.title).to_not eq('')
  #     end

  #     it 'returns http unprocessable_entity' do
  #       patch "/v1/tasks/#{task.id}", params: invalid_params
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end
  #   end
  # end

  # describe 'DELETE #destroy' do
  #   let!(:task) { FactoryBot.create(:task) }

  #   it 'destroys the requested task' do
  #     expect {
  #       delete "/v1/tasks/#{task.id}"
  #     }.to change(Task, :count).by(-1)
  #   end

  #   it 'returns http no_content' do
  #     delete "/v1/tasks/#{task.id}"
  #     expect(response).to have_http_status(204)
  #   end
  # end

  # after(:all) do
  #   # User.delete_all
  #   # Task.delete_all
  #   # Task.destroy_all
  #   # User.destroy_all
  #   # expect(Task.exists?(task.id)).to be_falsey
  #   # expect(User.exists?(user.id)).to be_falsey
  # end
end