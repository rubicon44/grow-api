module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      results = Search.search(model, contents, method)

      serialized_results = {}

      if results[:users].present?
        serialized_results[:users] = ActiveModelSerializers::SerializableResource.new(results[:users].order('users.id DESC'), each_serializer: UserSerializer)
      end
      if results[:tasks].present?
        serialized_results[:tasks] = ActiveModelSerializers::SerializableResource.new(results[:tasks].order('tasks.id DESC'), each_serializer: TaskSerializer, user: true)
      end

      render json: serialized_results, status: 200
    end
  end
end