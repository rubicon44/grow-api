# frozen_string_literal: true

require 'rails_helper'

# todo6: 「入力フォームに入力された値が文字列であるべき場合に、数値が渡された場合(ModelSpecで型キャスト前validationをテスト)」を処理
# todo7: describe, context, itのテストケースの分類を揃える
# todo8: エラー文言の修正(エラー文言の形式を揃える。英語と日本語のどちらを使用すべきか。完全でない文言はそのままで良いのか。)
# todo9: before_validationや、Modelのvalidation等を忘れずに。

RSpec.describe V1::TasksController, type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:headers) { { 'Authorization' => JsonWebToken.encode(user_email: user.email) } }

  describe 'GET #index (not logged in)' do
    it 'returns 401' do
      get '/v1/tasks'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #index (logged in)' do
    let!(:task1) { FactoryBot.create(:task, title: 'test_task1') }
    let!(:task2) { FactoryBot.create(:task, title: 'test_task2') }
    context 'when tasks exist' do
      it 'returns a list of tasks & 200' do
        get '/v1/tasks', headers: headers
        expect(response).to have_http_status(200)
        expect(response.body).to include(task1.title)
        expect(response.body).to include(task2.title)
      end
    end

    context 'when tasks do not exist' do
      it 'returns an empty list & 200' do
        Task.destroy_all
        get '/v1/tasks', headers: headers
        expect(response).to have_http_status(200)
        expect(response.body).to eq('{"tasks":[]}')
      end
    end
  end

  describe 'GET #show (not logged in)' do
    let!(:task) { FactoryBot.create(:task, title: 'test_task_show1') }
    it 'returns 401' do
      get "/v1/tasks/#{task.id}"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #show (logged in)' do
    let!(:task) { FactoryBot.create(:task, title: 'test_task_show1') }
    context 'when task exist' do
      it 'returns a task & 200' do
        get "/v1/tasks/#{task.id}", headers: headers
        expect(response).to have_http_status(200)
        expect(response.body).to include(task.title)
      end
    end

    context 'when task do not exist' do
      it 'returns an empty task & 404' do
        Task.destroy_all
        get "/v1/tasks/#{task.id}", headers: headers
        expect(response).to have_http_status(404)
        expect(response.body).to eq("{\"errors\":\"Couldn't find Task with 'id'=#{task.id}\"}")
      end
    end
  end

  describe 'GET #create (not logged in)' do
    it 'returns 401' do
      post '/v1/tasks'
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'POST #create (logged in)' do
    context 'creates a new task with valid params' do
      let!(:valid_params1) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create1', content: 'test_task_create1'),
          user_id: user.id }
      end
      it 'returns 204' do
        post '/v1/tasks', params: valid_params1, headers: headers
        expect(response).to have_http_status(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create1')
        expect(Task.last.content).to eq('test_task_create1')
      end

      let!(:valid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create2', content: ''), user_id: user.id }
      end
      it 'when content is empty & returns 204' do
        post '/v1/tasks', params: valid_params2, headers: headers
        expect(response.status).to eq(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create2')
        expect(Task.last.content).to eq('')
      end

      let!(:valid_params3) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create3', start_date: '', end_date: ''),
          user_id: user.id }
      end
      it 'when both start_date and end_date are blank & returns 204' do
        post '/v1/tasks', params: valid_params3, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create3')
        expect(Task.last.start_date).to eq(Date.today.to_s)
        expect(Task.last.end_date).to eq((Date.today + 1).to_s)
      end

      let!(:valid_params4) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create4', start_date: '', end_date: '2023-05-10'),
          user_id: user.id }
      end
      it 'when start_date is blank and returns 204' do
        post '/v1/tasks', params: valid_params4, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create4')
        expect(Task.last.start_date).to eq('2023-05-09')
      end

      let!(:valid_params5) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create5', start_date: '2023-05-10', end_date: ''),
          user_id: user.id }
      end
      it 'when end_date is blank and returns 204' do
        post '/v1/tasks', params: valid_params5, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create5')
        expect(Task.last.end_date).to eq('2023-05-11')
      end
    end

    context 'do not create a new task with invalid params' do
      # title
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)
      ## 入力フォームに入力された値が文字列であるべき場合に、数値が渡された場合(ModelSpecで型キャスト前validationをテスト)

      let!(:invalid_params1) { { task: FactoryBot.attributes_for(:task, title: 'a' * 256) } }
      it 'when title is too long & returns 422' do
        post '/v1/tasks', params: invalid_params1, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['title']).to include('は255文字以内で入力してください')
      end

      # content
      let!(:invalid_params2) { { task: FactoryBot.attributes_for(:task, content: 'a' * 5001) } }
      it 'when content exceeds the maximum length & returns 422' do
        post '/v1/tasks', params: invalid_params2, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['content']).to include('は5000文字以内で入力してください')
      end

      # status
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:invalid_params3) { { task: FactoryBot.attributes_for(:task, status: 4) } }
      it 'when a status other than 0, 1, 2, 3 is specified in the input form & returns 422' do
        post '/v1/tasks', params: invalid_params3, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['status']).to include('には0、1、2、3以外の数値を入力しないでください')
      end

      # start_date、end_date
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:invalid_params4) do
        { task: FactoryBot.attributes_for(:task, start_date: '20230101', end_date: '20231231') }
      end
      it 'with invalid date format & returns 422' do
        post '/v1/tasks', params: invalid_params4, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['start_date']).to include('は不正な値です')
        expect(response_body['errors']['end_date']).to include('は不正な値です')
      end

      let!(:invalid_params5) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-01-011', end_date: '2023-12-311') }
      end
      it 'when start date and end date is exceeding the character limit & returns 422' do
        post '/v1/tasks', params: invalid_params5, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['start_date']).to include('は不正な値です')
        expect(response_body['errors']['end_date']).to include('は不正な値です')
      end

      let!(:invalid_params6) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-05-05', end_date: '2023-05-01') }
      end
      it 'when end_date is before start_date & returns 422' do
        post '/v1/tasks', params: invalid_params6, headers: headers
        expect(response.status).to eq 422
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('End date must be after start date')
      end
    end
  end

  describe 'PUT #update (not logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user) }
    it 'returns 401' do
      put "/v1/tasks/#{task.id}"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'PUT #update (logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user) }
    context 'updates the requested task with valid params' do
      let!(:update_valid_params1) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update1', content: 'test_task_update1'),
          current_user_id: user.id }
      end
      it 'returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params1, headers: headers
        expect(response).to have_http_status(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update1')
        expect(Task.last.content).to eq('test_task_update1')
      end

      let!(:update_valid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update2', content: ''), current_user_id: user.id }
      end
      it 'when content is empty & returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params2, headers: headers
        expect(response.status).to eq(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update2')
        expect(Task.last.content).to eq('')
      end

      let!(:update_valid_params3) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update3', start_date: '', end_date: ''),
          current_user_id: user.id }
      end
      it 'when both start_date and end_date are blank & returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params3, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update3')
        expect(Task.last.start_date).to eq(Date.today.to_s)
        expect(Task.last.end_date).to eq((Date.today + 1).to_s)
      end

      let!(:update_valid_params4) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update4', start_date: '', end_date: '2023-05-10'),
          current_user_id: user.id }
      end
      it 'when start_date is blank and returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params4, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update4')
        expect(Task.last.start_date).to eq('2023-05-09')
      end

      let!(:update_valid_params5) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update5', start_date: '2023-05-10', end_date: ''),
          current_user_id: user.id }
      end
      it 'when end_date is blank and returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params5, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update5')
        expect(Task.last.end_date).to eq('2023-05-11')
      end
    end

    context 'do not update the requested task with invalid params' do
      # title
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)
      ## 入力フォームに入力された値が文字列であるべき場合に、数値が渡された場合(ModelSpecで型キャスト前validationをテスト)

      let!(:update_invalid_params1) do
        { task: FactoryBot.attributes_for(:task, title: 'a' * 256), current_user_id: user.id }
      end
      it 'when title is too long & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params1, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['title']).to include('は255文字以内で入力してください')
      end

      # content
      let!(:update_invalid_params2) do
        { task: FactoryBot.attributes_for(:task, content: 'a' * 5001), current_user_id: user.id }
      end
      it 'when content exceeds the maximum length & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params2, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['content']).to include('は5000文字以内で入力してください')
      end

      # status
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:update_invalid_params3) { { task: FactoryBot.attributes_for(:task, status: 4), current_user_id: user.id } }
      it 'when a status other than 0, 1, 2, 3 is specified in the input form & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params3, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['status']).to include('には0、1、2、3以外の数値を入力しないでください')
      end

      # start_date、end_date
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:update_invalid_params4) do
        { task: FactoryBot.attributes_for(:task, start_date: '20230101', end_date: '20231231'),
          current_user_id: user.id }
      end
      it 'with invalid date format & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params4, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['start_date']).to include('は不正な値です')
        expect(response_body['errors']['end_date']).to include('は不正な値です')
      end

      let!(:update_invalid_params5) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-01-011', end_date: '2023-12-311'),
          current_user_id: user.id }
      end
      it 'with start date and end date exceeding the character limit & returns 422 ' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params5, headers: headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']['start_date']).to include('は不正な値です')
        expect(response_body['errors']['end_date']).to include('は不正な値です')
      end

      let!(:update_invalid_params6) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-05-05', end_date: '2023-05-01'),
          current_user_id: user.id }
      end
      it 'when end_date is before start_date & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params6, headers: headers
        expect(response.status).to eq 422
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('End date must be after start date')
      end
    end

    context 'update non-existent tasks' do
      let!(:update_invalid_params7) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update', content: 'test_task_update'),
          current_user_id: user.id }
      end
      it 'returns 404' do
        put '/v1/tasks/0', params: update_invalid_params7, headers: headers
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include("Couldn't find Task with 'id'=0")
      end
    end

    context 'when an unauthorized user update a task' do
      let!(:user2) { FactoryBot.create(:user) }
      let!(:update_invalid_params8) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update', content: 'test_task_update'),
          current_user_id: user2.id }
      end
      it 'returns 403' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params8, headers: headers
        expect(response).to have_http_status(403)
        expect(Task.last.title).not_to eq('test_task_update')
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('You are not authorized to update this task')
      end
    end
  end

  describe 'DELETE #destroy (not logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user) }
    it 'returns 401' do
      delete "/v1/tasks/#{task.id}"
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'DELETE #destroy (logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user) }
    context 'delete the requested task when tasks exist' do
      let!(:delete_valid_params1) { { task: FactoryBot.attributes_for(:task), current_user_id: user.id } }
      it 'returns 204' do
        delete "/v1/tasks/#{task.id}", params: delete_valid_params1, headers: headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(0)
        expect(response.body).to eq('')
      end
    end

    context 'do not delete the requested task when tasks is non-existent' do
      let!(:delete_valid_params2) { { task: FactoryBot.attributes_for(:task), current_user_id: user.id } }
      it 'returns 404' do
        Task.destroy_all
        delete "/v1/tasks/#{task.id}", params: delete_valid_params2, headers: headers
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include("Couldn't find Task with 'id'=#{task.id}")
      end
    end

    context 'do not delete the requested task when an unauthorized user delete a task' do
      let!(:user2) { FactoryBot.create(:user) }
      let!(:delete_invalid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_delete'), current_user_id: user2.id }
      end
      it 'returns 403' do
        delete "/v1/tasks/#{task.id}", params: delete_invalid_params2, headers: headers
        expect(response).to have_http_status(403)
        expect(Task.last.title).not_to eq('test_task_delete')
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('You are not authorized to delete this task')
      end
    end
  end
end
