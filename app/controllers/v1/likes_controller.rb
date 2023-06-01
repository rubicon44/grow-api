# frozen_string_literal: true

module V1
  class LikesController < ApiController
    def index
      task = Task.find_by(id: params[:task_id])

      return render_task_not_found if task.nil?

      likes = Like.where(task_id: params[:task_id])
      like_count = likes.count
      likes_data = ActiveModel::Serializer::CollectionSerializer.new(likes, each_serializer: LikeSerializer).as_json
      render json: { likes: likes_data, like_count: like_count }, status: :ok
    end

    def create
      like_params = params_like_create
      current_user = User.find_by(id: like_params[:current_user_id])
      task = Task.find_by(id: like_params[:task_id])

      return render_task_not_found if task.nil?
      return render_invalid_parameters if current_user.nil? || task.nil?
      return render_user_already_liked if Like.user_already_liked?(current_user, task)

      Like.create_like_and_notification(current_user, task)
      render_no_content
    end

    def destroy
      current_user = User.find_by(id: params[:current_user_id])
      task = Task.find_by(id: params[:task_id])
      likes = Like.where(task_id: params[:task_id])

      return render_invalid_parameters if current_user.nil?
      return render_task_not_found if task.nil?
      return render_like_not_found if likes.empty?
      return render_forbidden unless Like.user_owns_likes?(current_user, likes)

      current_user.unlike(task)
      head :no_content, status: 204
    end

    private

    # TODO: delete時のstrong_parameterを作成するか検討。
    def params_like_create
      params.permit(:task_id, :current_user_id)
    end

    def render_forbidden
      render json: { errors: "Cannot delete other user's likes" }, status: :forbidden
    end

    def render_like_not_found
      render json: { errors: 'Likes not found' }, status: :not_found
    end

    def render_no_content
      render json: {}, status: :no_content
    end

    def render_task_not_found
      render json: { errors: 'Task not found' }, status: :not_found
    end

    def render_invalid_parameters
      render json: { errors: 'Invalid parameters' }, status: :unprocessable_entity
    end

    def render_user_already_liked
      render json: { errors: 'Conflict: User has already liked this task' }, status: :conflict
    end
  end
end
