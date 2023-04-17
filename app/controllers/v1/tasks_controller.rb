module V1
  class TasksController < ApiController
    # skip_before_action :check_authenticate!, only: %i(index), raise: false

    def index
      @task = Task.all
      render json: @task, include: [:user]
    end

    def show
      @task = Task.find(params[:id])
      render json: @task, include: [:user]
    end

    def create
      @task = Task.new(task_params)
      @user = User.find_by(firebase_id: params[:user_id])
      @task.user_id = @user.id

      if @task.save
        render json: @task, status: 201
      else
        render json: @task.errors, status: 500
      end
    end

    def update
      @task = Task.find(params[:id])
      if @task.update(task_params)
        render json: @task, status: 201
      end
    end

    def destroy
      @task = Task.find(params[:id])
      if @task.destroy
        head :no_content, status: :ok
      else
        render json: @task.errors, status: :unprocessable_entity
      end
    end

    private

    def task_params
      params.require(:task).permit(:title, :content, :status, :start_date, :end_date, :user_id)
    end
  end
end