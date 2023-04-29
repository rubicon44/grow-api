module V1
  class TasksController < ApiController
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
      task.user_id = User.find_by(firebase_id: params[:user_id]).id
      render json: {}, status: 201 if task.save
    end

    def update
      task = Task.find(params[:id])
      render json: {}, status: 201 if task.update(task_params)
    end

    def destroy
      task = Task.find(params[:id])
      head :no_content, status: 204 if task.destroy
    end

    private

    def task_params
      params.require(:task).permit(:title, :content, :status, :start_date, :end_date, :user_id)
    end
  end
end