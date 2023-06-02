# frozen_string_literal: true

module V1
  class TasksController < ApiController
    before_action :require_task_owner, only: %i[update destroy]
    def index
      # TODO: ページネーションの追加
      tasks = Task.includes(:user).order('tasks.id DESC')
      tasks_data = serialize_tasks_with_users(tasks)
      render json: { tasks: tasks_data }, status: :ok
    end

    def show
      task = find_task
      return render_not_found unless task

      render json: serialize_task_with_user(task), status: :ok
    end

    def create
      task = Task.new(task_params)
      task.user_id = params[:user_id]
      task.save ? render_no_content : render_invalid_parameters(task.errors)
    end

    def update
      task = find_task
      task.update(task_params) ? render_no_content : render_invalid_parameters(task.errors)
    end

    def destroy
      task = find_task
      task.destroy ? render_no_content : render_not_destroyed
    end

    private

    def task_params
      params.require(:task).permit(:title, :content, :status, :start_date, :end_date, :user_id)
    end

    def find_task
      Task.find_by(id: params[:id])
    end

    def require_task_owner
      task = find_task
      current_user_id = params[:current_user_id].to_i

      error_message = if request.method == 'PUT'
                        'update'
                      elsif request.method == 'DELETE'
                        'delete'
                      end

      render_forbidden(error_message) if error_message && task.user_id != current_user_id
    end

    def serialize_tasks_with_users(tasks)
      TaskSerializer.serialize_tasks_collection(tasks)
    end

    def serialize_task_with_user(task)
      task_data = TaskSerializer.serialize_task(task)
      task_user = User.find(task.user_id)
      task_data.merge(user: TaskSerializer.serialize_user(task_user))
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

    def render_not_destroyed
      render json: { errors: 'Task could not be destroyed' }, status: :unprocessable_entity
    end

    def render_not_found
      render json: { errors: 'Task not found' }, status: :not_found
    end
  end
end
