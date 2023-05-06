module V1
  class LikesController < ApiController
    def index
      likes = Like.where(task_id: params[:task_id])
      like_count = likes.count
      likes_data = ActiveModel::Serializer::CollectionSerializer.new(likes, each_serializer: LikeSerializer).as_json
      render json: { likes: likes_data, like_count: like_count }, status: 200
    end

    def create
      current_user = User.find(params[:current_user_id])
      task = Task.find(params[:task_id])
      current_user.like(task)

      noti_task = Task.find(params[:task_id])
      noti_task.create_notification_like!(current_user)

      render json: {}, status: 204
    end

    def destroy
      current_user = User.find(params[:current_user_id])
      task = Task.find(params[:task_id])
      current_user.unlike(task)
      head :no_content, status: 204
    end

    private

    def params_like_create
      params.require(:like).permit(:task_id, :current_user_id)
    end
  end
end