# frozen_string_literal: true

module V1
  class LikesController < ApiController
    def index
      task = Task.includes(likes: :user).find_by(id: params[:task_id])
      return render_not_found('Task') unless task

      likes = task.likes
      like_count = likes.count
      likes_data = LikeSerializer.serialize_likes_collection(likes)
      render json: { likes: likes_data, like_count: like_count }, status: :ok
    end

    def create
      like_params = params_like_create
      current_user = User.includes(:tasks, :likes).find_by(id: like_params[:current_user_id])
      task = Task.includes(:user, :likes, :notifications).find_by(id: like_params[:task_id])

      return render_unprocessable('Current User') if current_user.nil?
      return render_not_found('Task') unless task
      return render_conflict('User has already liked this task') if Like.user_already_liked?(current_user,
                                                                                             task)

      render_no_content if Like.create_like_and_notification(current_user, task)
    end

    def destroy
      current_user = User.includes(:tasks, :likes).find_by(id: params[:current_user_id])
      return render_unprocessable('Current User') if current_user.nil?

      task = Task.includes(:user, :likes, :notifications).find_by(id: params[:task_id])
      likes = task.likes if task

      return render_not_found('Task') unless task
      return render_not_found('Likes') if likes.empty?
      return render_forbidden("Cannot delete other user's likes") unless Like.user_owns_likes?(current_user, likes)

      render_no_content if current_user.unlike(task)
    end

    private

    # TODO: delete時のstrong_parameterを作成するか検討。
    def params_like_create
      params.permit(:task_id, :current_user_id)
    end
  end
end
