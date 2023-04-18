module V1
  class LikesController < ApiController
    skip_before_action :check_authenticate!, only: %i(index, create, destroy), raise: false

    def index
      likes = Like.where(task_id: params[:task_id])
      like_count = likes.count

      user_like = likes.find_by(user_id: params[:current_user_id])
      task_id = user_like&.task_id
      liked_user_id = user_like&.user_id
      like_id = user_like&.id

      render json: { task_id: task_id, like_count: like_count, liked_user_id: liked_user_id, like_id: like_id }
    end

    def show
    end

    def create
      @task = Task.find(params[:task_id])
      @task_id = @task.id
      @current_user = User.find(params[:current_user_id])
      @current_user.like(@task)

      @like_count = Like.count(params[:task_id])
      @like = Like.find_by(user_id: params[:current_user_id])
      if @like.present?
        @liked_user_id = @like.user_id
        @like_id = @like.id
      end

      # like notification(Not render this)
      @noti_task = Task.find(params[:task_id])
      @current_user = User.find(params[:current_user_id])
      @noti_task.create_notification_like!(@current_user)

      render json: { task_id: @task_id, like_count: @like_count, liked_user_id: @liked_user_id, like_id: @like_id }
    end

    def destroy
      @task = Task.find(params[:task_id])
      @current_user = User.find(params[:current_user_id])
      @current_user.unlike(@task)

      @like_count = Like.count(params[:task_id])
      @like = Like.find_by(user_id: params[:current_user_id])
      if @like.present?
        @liked_user_id = @like.user_id
        @like_id = @like.id
      end
      render json: { like_count: @like_count, liked_user_id: @liked_user_id, like_id: @like_id }
    end

    private

    def params_like_create
      params.require(:like).permit(:task_id, :current_user_id)
    end
  end
end