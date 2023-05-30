# frozen_string_literal: true

module V1
  class LikesController < ApiController
    def index
      task = Task.find_by(id: params[:task_id])

      if task.nil?
        render json: { error: 'Task not found' }, status: :not_found
        return
      end

      likes = Like.where(task_id: params[:task_id])
      like_count = likes.count
      likes_data = ActiveModel::Serializer::CollectionSerializer.new(likes, each_serializer: LikeSerializer).as_json
      render json: { likes: likes_data, like_count: like_count }, status: :ok
    end

    def create
      like_params = params_like_create
      current_user = User.find_by(id: like_params[:current_user_id])
      task = Task.find_by(id: like_params[:task_id])

      if task.nil?
        render json: { error: 'Task not found' }, status: :not_found
        return
      end

      if current_user.nil? || task.nil?
        render json: { error: 'Invalid parameters' }, status: :unprocessable_entity
        return
      end

      if current_user.likes.exists?(task_id: task.id)
        render json: { error: 'Conflict: User has already liked this task' }, status: :conflict
      else
        current_user.like(task)
        noti_task = Task.find(like_params[:task_id])
        noti_task.create_notification_like!(current_user)
        render json: {}, status: :no_content
      end
    end

    def destroy
      current_user = User.find_by(id: params[:current_user_id])
      task = Task.find_by(id: params[:task_id])
      likes = Like.where(task_id: params[:task_id])

      if current_user.nil?
        render json: { error: 'Invalid parameters' }, status: :unprocessable_entity
        return
      end

      if task.nil?
        render json: { error: 'Task not found' }, status: :not_found
        return
      end

      if likes.empty?
        render json: { error: 'Likes not found' }, status: :not_found
        return
      end

      if likes.pluck(:user_id).exclude?(current_user.id)
        render json: { error: "Cannot delete other user's likes" }, status: :forbidden
        return
      end

      current_user.unlike(task)
      head :no_content, status: 204
    end

    private

    # TODO: delete時のstrong_parameterを作成するか検討。
    def params_like_create
      params.permit(:task_id, :current_user_id)
    end
  end
end
