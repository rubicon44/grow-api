module V1
  # todo: serializerロジックを「app/serializers/」以下ファイル内に移行
  class TasksController < ApiController
    before_action :require_task_owner, only: [:update, :destroy]
    def index
      tasks = Task.all.order('tasks.id DESC')
      tasks_data = ActiveModel::Serializer::CollectionSerializer.new(tasks, each_serializer: TaskSerializer).as_json
      tasks_data.each do |task|
        task_user = User.find(task[:user_id])
        task[:user] = UserSerializer.new(task_user).as_json
      end
      render json: { tasks: tasks_data }, status: 200
    end

    def show
      task = Task.find(params[:id])
      task_data = TaskSerializer.new(task).as_json
      task_user = User.find(task.user_id)
      task_data[:user] = UserSerializer.new(task_user).as_json
      render json: task_data, status: 200
    end

    def create
      task = Task.new(task_params)
      task.user_id = params[:user_id]
      render json: {}, status: 204 if task.save
    end

    def update
      task = Task.find(params[:id])
      render json: {}, status: 204 if task.update(task_params)
    end

    def destroy
      task = Task.find(params[:id])
      head :no_content, status: 204 if task.destroy
    end

    private

    def task_params
      params.require(:task).permit(:title, :content, :status, :start_date, :end_date, :user_id)
    end

    def require_task_owner
      task = Task.find(params[:id])
      current_user_id = params[:current_user_id]
      unless task.user_id == current_user_id
        render json: { errors: "You are not authorized to update this task" }, status: 403
      end
    end
  end
end