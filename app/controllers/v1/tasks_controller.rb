# frozen_string_literal: true

module V1
  class TasksController < ApiController
    before_action :require_task_owner, only: %i[update destroy]
    def index
      page = params[:page].to_i
      page_size = params[:page_size].to_i

      tasks = Task.includes(:user).order('tasks.id DESC')
      following_user_tasks = fetch_following_user_tasks

      tasks_data = serialize_tasks_with_users(paginate_tasks(tasks, page, page_size))
      following_user_tasks_data = serialize_tasks_with_users(paginate_tasks(following_user_tasks, page, page_size))

      render json: { tasks: tasks_data, following_user_tasks: following_user_tasks_data }, status: :ok
    end

    def show
      task = find_task
      return render_not_found('Task') unless task

      render json: serialize_task_with_user(task), status: :ok
    end

    def create
      task = Task.new(task_params)
      task.user_id = params[:user_id]
      task.save ? render_no_content : render_unprocessable_entity(task)
    end

    def update
      task = find_task
      return render_not_found('Task') unless task

      task.update(task_params) ? render_no_content : render_unprocessable_entity(task)
    end

    def destroy
      task = find_task
      task.destroy ? render_no_content : render_not_destroyed('Task')
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
      return render_not_found('Task') unless task

      current_user_id = params[:current_user_id].to_i

      error_message = if request.method == 'PUT'
                        'update'
                      elsif request.method == 'DELETE'
                        'delete'
                      end

      return unless error_message && task.user_id != current_user_id

      render_forbidden("You are not authorized to #{error_message} this task")
    end

    def fetch_following_user_tasks
      current_user = User.find_by(id: params[:current_user_id])
      return [] unless current_user

      following_user_ids = current_user.followings.pluck(:id)
      Task.includes(:user).where(user_id: following_user_ids).order('tasks.id DESC')
    end

    def paginate_tasks(tasks, page, page_size)
      return [] if tasks.blank?

      tasks.limit(page_size).offset((page - 1) * page_size)
    end

    def serialize_tasks_with_users(tasks)
      TaskSerializer.serialize_tasks_collection(tasks)
    end

    def serialize_task_with_user(task)
      task_data = TaskSerializer.serialize_task(task)
      task_user = User.find(task.user_id)
      task_data.merge(user: TaskSerializer.serialize_user(task_user))
    end
  end
end
