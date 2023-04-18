module V1
  class SearchesController < ApiController
    def index
      contents = params[:contents]
      model = params[:model]
      method = params[:method]
      results = Search.search(model, contents, method)

      serialized_results = {}

      if results[:users].present?
        serialized_results[:users] = ActiveModelSerializers::SerializableResource.new(results[:users], each_serializer: UserSerializer)
      end

      if results[:tasks].present?
        serialized_results[:tasks] = ActiveModelSerializers::SerializableResource.new(results[:tasks], each_serializer: TaskSerializer)
      end

      if results[:task_users].present?
        serialized_results[:task_users] = ActiveModelSerializers::SerializableResource.new(results[:task_users], each_serializer: UserSerializer)
      end

      render json: { results: serialized_results }
    end
  end
end