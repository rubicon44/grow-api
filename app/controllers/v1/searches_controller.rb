# frozen_string_literal: true

module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      return render_bad_request('search model') unless valid_model?(model)

      results = Search.search(model, contents, method)
      serialized_results = serialize_results(results)

      render json: serialized_results, status: :ok
    end

    private

    def serialize_results(results)
      serialized_results = {}
      serialized_results[:tasks] = serialize_tasks(results[:tasks]) if results[:tasks].present?
      serialized_results[:users] = serialize_users(results[:users]) if results[:users].present?
      serialized_results
    end

    def serialize_tasks(tasks)
      TaskSerializer.serialize_tasks_collection(tasks.order('tasks.id DESC'))
    end

    def serialize_users(users)
      UserSerializer.serialize_users_collection(users.order('users.id DESC'))
    end

    def valid_model?(model)
      %w[user task].include?(model)
    end
  end
end
