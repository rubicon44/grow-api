# frozen_string_literal: true

module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      results = Search.search(model, contents, method)

      serialized_results = {}
      serialized_results[:tasks] = serialize_tasks(results[:tasks]) if results[:tasks].present?
      serialized_results[:users] = serialize_users(results[:users]) if results[:users].present?

      render json: serialized_results, status: :ok
    end

    private

    def serialize_tasks(tasks)
      TaskSerializer.serialize_tasks_collection(tasks.order('tasks.id DESC'))
    end

    def serialize_users(users)
      UserSerializer.serialize_users_collection(users.order('users.id DESC'))
    end
  end
end
