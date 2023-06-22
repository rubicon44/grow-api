# frozen_string_literal: true

module V1
  class LikesController < ApiController
    def index
      task = Task.includes(:likes).find_by(id: params[:task_id])
      return render_not_found('Task') unless task

      likes = Like.where(task_id: params[:task_id])
      like_count = likes.count
      likes_data = LikeSerializer.serialize_likes_collection(likes)
      render json: { likes: likes_data, like_count: like_count }, status: :ok
    end

    def create
      like_params = params_like_create
      current_user = User.find_by(id: like_params[:current_user_id])
      task = Task.find_by(id: like_params[:task_id])

      return render_not_found('Task') unless task
      return render_unprocessable_entity(task) if current_user.nil?
      return render_conflict('User has already liked this task') if Like.user_already_liked?(current_user,
                                                                                             task)

      create_like(current_user, task)
    end

    def destroy
      current_user = User.find_by(id: params[:current_user_id])
      task = Task.find_by(id: params[:task_id])
      likes = Like.where(task_id: params[:task_id])

      return render_not_found('Task') unless task
      return render_not_found('Likes') if likes.empty?
      return render_forbidden("Cannot delete other user's likes") unless Like.user_owns_likes?(current_user, likes)

      delete_like(current_user, task)
    end

    private

    # TODO: delete時のstrong_parameterを作成するか検討。
    def params_like_create
      params.permit(:task_id, :current_user_id)
    end

    def create_like(current_user, task)
      if Like.create_like_and_notification(current_user, task)
        render_no_content
      else
        render_not_created('Like')
      end
    end

    def delete_like(current_user, task)
      if current_user.unlike(task)
        render_no_content
      else
        render_not_destroyed('Like')
      end
    end
  end
end
