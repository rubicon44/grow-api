# frozen_string_literal: true

module V1
  # TODO: serializerロジックを「app/serializers/」以下ファイル内に移行
  class TasksController < ApiController
    before_action :require_task_owner, only: %i[update destroy]
    def index
      tasks = Task.all.order('tasks.id DESC')
      tasks_data = serialize_tasks(tasks)
      render json: { tasks: tasks_data }, status: :ok
    end

    def show
      task = Task.find(params[:id])
      task_data = serialize_task(task)
      render json: task_data, status: :ok
    end

    def create
      task = Task.new(task_params)
      task.user_id = params[:user_id]
      task.save ? render_no_content : render_invalid_parameters(task.errors)
    end

    def update
      task = Task.find(params[:id])
      task.update(task_params) ? render_no_content : render_invalid_parameters(task.errors)
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
      current_user_id = params[:current_user_id].to_i

      error_message = if request.method == 'PUT'
                        'update'
                      elsif request.method == 'DELETE'
                        'delete'
                      end

      render_forbidden(error_message) if error_message && task.user_id != current_user_id
    end

    def serialize_tasks(tasks)
      tasks_data = ActiveModel::Serializer::CollectionSerializer.new(tasks, each_serializer: TaskSerializer).as_json
      tasks_data.map do |task|
        task_user = User.find(task[:user_id])
        task.merge(user: serialize_user(task_user))
      end
    end

    def serialize_task(task)
      task_data = TaskSerializer.new(task).as_json
      task_user = User.find(task.user_id)
      task_data.merge(user: serialize_user(task_user))
    end

    def serialize_user(user)
      UserSerializer.new(user).as_json
    end

    def render_forbidden(message)
      render json: { errors: "You are not authorized to #{message} this task" }, status: :forbidden
    end

    def render_invalid_parameters(message)
      render json: { errors: message }, status: :unprocessable_entity
    end

    def render_no_content
      render json: {}, status: :no_content
    end
  end
end
