# frozen_string_literal: true

module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      results = Search.search(model, contents, method)

      serialized_results = {}
      serialized_results[:users] = serialize_users(results[:users]) if results[:users].present?
      serialized_results[:tasks] = serialize_tasks(results[:tasks]) if results[:tasks].present?

      render json: serialized_results, status: :ok
    end

    private

    def serialize_users(users)
      ActiveModelSerializers::SerializableResource.new(users.order('users.id DESC'),
                                                       each_serializer: UserSerializer)
    end

    def serialize_tasks(tasks)
      ActiveModelSerializers::SerializableResource.new(tasks.order('tasks.id DESC'),
                                                       each_serializer: TaskSerializer, user: true)
    end
  end
end
