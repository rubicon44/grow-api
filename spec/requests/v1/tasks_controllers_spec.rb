# frozen_string_literal: true

require 'rails_helper'

# todo4: エラーレスポンスのフォーマットを統一する
## 1: expect(response.body).to eq('{"errors":"Authorization token is missing"}')
## 2: expect(response_body['errors']).to include("Title exceeds maximum length")

# todo5: エラーレスポンスの修正(例: 'は255文字以内で入力してください'を通す)

# todo6: 「入力フォームに入力された値が文字列であるべき場合に、数値が渡された場合(ModelSpecで型キャスト前validationをテスト)」を処理
# todo8: エラー文言の修正(エラー文言の形式を揃える。英語と日本語のどちらを使用すべきか。完全でない文言はそのままで良いのか。)

# todo9: before_validationや、Modelのvalidation等を忘れずに。

RSpec.describe V1::TasksController, type: :request do
  let!(:user1) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user) }

  let!(:auth_headers) { { 'Authorization' => JsonWebToken.encode(user_email: user1.email) } }
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
      get '/v1/tasks', headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  # infinite scrollを修正
  describe 'GET #index (logged in)' do
    context 'when tasks & following_user_tasks exist' do
      let!(:task1) { FactoryBot.create(:task, title: 'test_task1', user: user1) }
      let!(:task2) { FactoryBot.create(:task, title: 'test_task2', user: user2) }

      it 'returns a list of tasks & 200' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 1, page_size: 2 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['tasks'][1]['title']).to include(task1.title)
        expect(json_response['tasks'][0]['title']).to include(task2.title)
        expect(json_response['following_user_tasks'][0]['title']).to include(task2.title)
      end
    end

    context 'when tasks do not exist' do
      it 'returns an empty list & 200' do
        Task.destroy_all
        get '/v1/tasks', headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)
        expect(response.body).to eq('{"tasks":[],"following_user_tasks":[]}')
      end
    end

    # page_sizeは固定
    context 'infinite scroll of tasks with page_size: 1' do
      let!(:task1_by_user1) { FactoryBot.create(:task, title: 'test_task1_1', user: user1) }
      let!(:task2_by_user1) { FactoryBot.create(:task, title: 'test_task1_2', user: user1) }

      it 'returns a list of tasks & 200' do
        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 1, page_size: 1 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['tasks'][0]['title']).to include(task2_by_user1.title)

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 2, page_size: 1 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['tasks'][0]['title']).to include(task1_by_user1.title)
      end
    end

    context 'infinite scroll of following_user_tasks with page_size: 1' do
      let!(:task1_by_user2) { FactoryBot.create(:task, title: 'test_task2_1', user: user2) }
      let!(:task2_by_user2) { FactoryBot.create(:task, title: 'test_task2_2', user: user2) }

      it 'returns a list of tasks & 200' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 1, page_size: 1 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['following_user_tasks'][0]['title']).to include(task2_by_user2.title)

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 2, page_size: 1 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['following_user_tasks'][0]['title']).to include(task1_by_user2.title)
      end
    end

    context 'infinite scroll of tasks with page_size: 2' do
      let!(:task1_by_user1) { FactoryBot.create(:task, title: 'test_task1_1', user: user1) }
      let!(:task2_by_user1) { FactoryBot.create(:task, title: 'test_task1_2', user: user1) }
      let!(:task3_by_user1) { FactoryBot.create(:task, title: 'test_task1_3', user: user1) }
      let!(:task4_by_user1) { FactoryBot.create(:task, title: 'test_task1_4', user: user1) }

      it 'returns a list of tasks & 200' do
        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 1, page_size: 2 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['tasks'][1]['title']).to include(task3_by_user1.title)
        expect(json_response['tasks'][0]['title']).to include(task4_by_user1.title)

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 2, page_size: 2 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['tasks'][1]['title']).to include(task1_by_user1.title)
        expect(json_response['tasks'][0]['title']).to include(task2_by_user1.title)
      end
    end

    context 'infinite scroll of following_user_tasks with page_size: 2' do
      let!(:task1_by_user2) { FactoryBot.create(:task, title: 'test_task2_1', user: user2) }
      let!(:task2_by_user2) { FactoryBot.create(:task, title: 'test_task2_2', user: user2) }
      let!(:task3_by_user2) { FactoryBot.create(:task, title: 'test_task2_3', user: user2) }
      let!(:task4_by_user2) { FactoryBot.create(:task, title: 'test_task2_4', user: user2) }

      it 'returns a list of tasks & 200' do
        params = { following_id: user1.id, follower_id: user2.id }
        post "/v1/users/#{user1.id}/relationships", params: params, headers: csrf_token_auth_headers

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 1, page_size: 2 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['following_user_tasks'][1]['title']).to include(task3_by_user2.title)
        expect(json_response['following_user_tasks'][0]['title']).to include(task4_by_user2.title)

        get '/v1/tasks', headers: csrf_token_auth_headers, params: { current_user_id: user1.id, page: 2, page_size: 2 }
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['following_user_tasks'][1]['title']).to include(task1_by_user2.title)
        expect(json_response['following_user_tasks'][0]['title']).to include(task2_by_user2.title)
      end
    end
  end

  describe 'GET #show (not logged in)' do
    let!(:task) { FactoryBot.create(:task, title: 'test_task_show1') }
    it 'returns 401' do
      get "/v1/tasks/#{task.id}", headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'GET #show (logged in)' do
    let!(:task) { FactoryBot.create(:task, title: 'test_task_show1') }
    context 'when task exist' do
      it 'returns a task & 200' do
        get "/v1/tasks/#{task.id}", headers: csrf_token_auth_headers
        expect(response).to have_http_status(200)
        expect(response.body).to include(task.title)
      end
    end

    context 'when task do not exist' do
      it 'returns an empty task & 404' do
        Task.destroy_all
        get "/v1/tasks/#{task.id}", headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        expect(response.body).to eq('{"errors":"Task not found"}')
      end
    end
  end

  describe 'GET #create (not logged in)' do
    it 'returns 401' do
      post '/v1/tasks', headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'POST #create (logged in)' do
    context 'creates a new task with valid params' do
      let!(:valid_params1) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create1', content: 'test_task_create1'),
          user_id: user1.id }
      end

      it 'returns 204' do
        post '/v1/tasks', params: valid_params1, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create1')
        expect(Task.last.content).to eq('test_task_create1')
      end

      let!(:valid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create2', content: ''), user_id: user1.id }
      end
      it 'when content is empty & returns 204' do
        post '/v1/tasks', params: valid_params2, headers: csrf_token_auth_headers
        expect(response.status).to eq(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create2')
        expect(Task.last.content).to eq('')
      end

      let!(:valid_params3) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create3', start_date: '', end_date: ''),
          user_id: user1.id }
      end
      it 'when both start_date and end_date are blank & returns 204' do
        post '/v1/tasks', params: valid_params3, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create3')
        expect(Task.last.start_date).to eq(Time.zone.today.to_s)
        expect(Task.last.end_date).to eq((Time.zone.today + 1).to_s)
      end

      let!(:valid_params4) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create4', start_date: '', end_date: '2023-05-10'),
          user_id: user1.id }
      end
      it 'when start_date is blank and returns 204' do
        post '/v1/tasks', params: valid_params4, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_create4')
        expect(Task.last.start_date).to eq('2023-05-09')
      end

      let!(:valid_params5) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_create5', start_date: '2023-05-10', end_date: ''),
          user_id: user1.id }
      end
      it 'when end_date is blank and returns 204' do
        post '/v1/tasks', params: valid_params5, headers: csrf_token_auth_headers
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
        post '/v1/tasks', params: invalid_params1, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Title exceeds maximum length')
        # expect(response_body['errors']).to include('は255文字以内で入力してください')
      end

      # content
      let!(:invalid_params2) { { task: FactoryBot.attributes_for(:task, content: 'a' * 5001) } }
      it 'when content exceeds the maximum length & returns 422' do
        post '/v1/tasks', params: invalid_params2, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Content exceeds maximum length')
        # expect(response_body['errors']).to include('は5000文字以内で入力してください')
      end

      # status
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:invalid_params3) { { task: FactoryBot.attributes_for(:task, status: 4) } }
      it 'when a status other than 0, 1, 2, 3 is specified in the input form & returns 422' do
        post '/v1/tasks', params: invalid_params3, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Status is invalid')
      end

      # start_date、end_date
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:invalid_params4) do
        { task: FactoryBot.attributes_for(:task, start_date: '20230101', end_date: '20231231') }
      end
      it 'with invalid date format & returns 422' do
        post '/v1/tasks', params: invalid_params4, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Start date has invalid format')
        expect(response_body['errors']).to include('End date has invalid format')
      end

      let!(:invalid_params5) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-01-011', end_date: '2023-12-311') }
      end
      it 'when start date and end date is exceeding the character limit & returns 422' do
        post '/v1/tasks', params: invalid_params5, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Start date has invalid format')
        expect(response_body['errors']).to include('End date has invalid format')
      end

      let!(:invalid_params6) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-05-05', end_date: '2023-05-01') }
      end
      it 'when end_date is before start_date & returns 422' do
        post '/v1/tasks', params: invalid_params6, headers: csrf_token_auth_headers
        expect(response.status).to eq 422
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('End date must be after start date')
      end
    end
  end

  describe 'PUT #update (not logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user1) }
    it 'returns 401' do
      put "/v1/tasks/#{task.id}", headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'PUT #update (logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user1) }

    context 'updates the requested task with valid params' do
      let!(:update_valid_params1) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update1', content: 'test_task_update1'),
          current_user_id: user1.id }
      end

      it 'returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params1, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update1')
        expect(Task.last.content).to eq('test_task_update1')
      end

      let!(:update_valid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update2', content: ''), current_user_id: user1.id }
      end
      it 'when content is empty & returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params2, headers: csrf_token_auth_headers
        expect(response.status).to eq(204)
        expect(response.body).to be_empty
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update2')
        expect(Task.last.content).to eq('')
      end

      let!(:update_valid_params3) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update3', start_date: '', end_date: ''),
          current_user_id: user1.id }
      end
      it 'when both start_date and end_date are blank & returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params3, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update3')
        expect(Task.last.start_date).to eq(Time.zone.today.to_s)
        expect(Task.last.end_date).to eq((Time.zone.today + 1).to_s)
      end

      let!(:update_valid_params4) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update4', start_date: '', end_date: '2023-05-10'),
          current_user_id: user1.id }
      end
      it 'when start_date is blank and returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params4, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(1)
        expect(Task.last.title).to eq('test_task_update4')
        expect(Task.last.start_date).to eq('2023-05-09')
      end

      let!(:update_valid_params5) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update5', start_date: '2023-05-10', end_date: ''),
          current_user_id: user1.id }
      end
      it 'when end_date is blank and returns 204' do
        put "/v1/tasks/#{task.id}", params: update_valid_params5, headers: csrf_token_auth_headers
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
        { task: FactoryBot.attributes_for(:task, title: 'a' * 256), current_user_id: user1.id }
      end
      it 'when title is too long & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params1, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Title exceeds maximum length')
      end

      # content
      let!(:update_invalid_params2) do
        { task: FactoryBot.attributes_for(:task, content: 'a' * 5001), current_user_id: user1.id }
      end
      it 'when content exceeds the maximum length & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params2, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Content exceeds maximum length')
      end

      # status
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:update_invalid_params3) { { task: FactoryBot.attributes_for(:task, status: 4), current_user_id: user1.id } }
      it 'when a status other than 0, 1, 2, 3 is specified in the input form & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params3, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Status is invalid')
      end

      # start_date、end_date
      ## 入力フォームに入力されるべき値が空の場合(ModelSpecのインスタンスメソッドをテスト)

      let!(:update_invalid_params4) do
        { task: FactoryBot.attributes_for(:task, start_date: '20230101', end_date: '20231231'),
          current_user_id: user1.id }
      end
      it 'with invalid date format & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params4, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Start date has invalid format')
        expect(response_body['errors']).to include('End date has invalid format')
      end

      let!(:update_invalid_params5) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-01-011', end_date: '2023-12-311'),
          current_user_id: user1.id }
      end
      it 'with start date and end date exceeding the character limit & returns 422 ' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params5, headers: csrf_token_auth_headers
        expect(response).to have_http_status(422)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Start date has invalid format')
        expect(response_body['errors']).to include('End date has invalid format')
      end

      let!(:update_invalid_params6) do
        { task: FactoryBot.attributes_for(:task, start_date: '2023-05-05', end_date: '2023-05-01'),
          current_user_id: user1.id }
      end
      it 'when end_date is before start_date & returns 422' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params6, headers: csrf_token_auth_headers
        expect(response.status).to eq 422
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('End date must be after start date')
      end
    end

    context 'update non-existent tasks' do
      let!(:update_invalid_params7) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update', content: 'test_task_update'),
          current_user_id: user1.id }
      end
      it 'returns 404' do
        put '/v1/tasks/0', params: update_invalid_params7, headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Task not found')
      end
    end

    context 'when an unauthorized user update a task' do
      let!(:update_invalid_params8) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_update', content: 'test_task_update'),
          current_user_id: user2.id }
      end
      it 'returns 403' do
        put "/v1/tasks/#{task.id}", params: update_invalid_params8, headers: csrf_token_auth_headers
        expect(response).to have_http_status(403)
        expect(Task.last.title).not_to eq('test_task_update')
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('You are not authorized to update this task')
      end
    end
  end

  describe 'DELETE #destroy (not logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user1) }
    it 'returns 401' do
      delete "/v1/tasks/#{task.id}", headers: csrf_token_headers
      expect(response).to have_http_status(401)
      expect(response.body).to eq('{"errors":"Authorization token is missing"}')
    end
  end

  describe 'DELETE #destroy (logged in)' do
    let!(:task) { FactoryBot.create(:task, user: user1) }
    context 'delete the requested task when tasks exist' do
      let!(:delete_valid_params1) { { task: FactoryBot.attributes_for(:task), current_user_id: user1.id } }
      it 'returns 204' do
        delete "/v1/tasks/#{task.id}", params: delete_valid_params1, headers: csrf_token_auth_headers
        expect(response).to have_http_status(204)
        expect(Task.count).to eq(0)
        expect(response.body).to eq('')
      end
    end

    context 'do not delete the requested task when tasks is non-existent' do
      let!(:delete_valid_params2) { { task: FactoryBot.attributes_for(:task), current_user_id: user1.id } }
      it 'returns 404' do
        Task.destroy_all
        delete "/v1/tasks/#{task.id}", params: delete_valid_params2, headers: csrf_token_auth_headers
        expect(response).to have_http_status(404)
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('Task not found')
      end
    end

    context 'do not delete the requested task when an unauthorized user delete a task' do
      let!(:delete_invalid_params2) do
        { task: FactoryBot.attributes_for(:task, title: 'test_task_delete'), current_user_id: user2.id }
      end
      it 'returns 403' do
        delete "/v1/tasks/#{task.id}", params: delete_invalid_params2, headers: csrf_token_auth_headers
        expect(response).to have_http_status(403)
        expect(Task.last.title).not_to eq('test_task_delete')
        response_body = JSON.parse(response.body)
        expect(response_body['errors']).to include('You are not authorized to delete this task')
      end
    end
  end
end
