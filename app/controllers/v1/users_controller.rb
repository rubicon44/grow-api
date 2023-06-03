# frozen_string_literal: true

module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false
    def show
      user = find_user

      if user.nil?
        render_not_found('User')
      else
        render json: serialize_user_data(user), status: :ok
      end
    end

    def followings
      user = find_user
      return render_not_found('User') if user.nil?

      followings = user.followings.order('relationships.id DESC')
      render json: { followings: UserSerializer.serialize_users_collection(followings) }, status: :ok
    end

    def followers
      user = find_user
      return render_not_found('User') if user.nil?

      followers = user.followers.order('relationships.id DESC')
      render json: { followers: UserSerializer.serialize_users_collection(followers) }, status: :ok
    end

    def create
      user = User.new(params_user_create)

      if [user.nickname, user.username, user.email, user.firebase_id].any?(&:nil?)
        return render_unprocessable_entity(user)
      end

      user.save ? render_no_content : render_unprocessable_entity(user)
    end

    def update
      user = find_user
      return render_not_found('User') if user.nil?

      current_user_id = params[:current_user_id].to_i
      method = request.method.downcase
      return render_forbidden("You are not authorized to #{method} this user") unless require_user_authorization(
        user.id, current_user_id
      )

      update_user(user)
    end

    # TODO: 追加予定
    # def destroy

    private

    def params_user_create
      params.require(:user).permit(:nickname, :username, :email, :firebase_id)
    end

    def params_user_update
      params.require(:user).permit(:nickname, :username, :bio)
    end

    def find_user
      User.find_by(username: params[:username])
    end

    def require_user_authorization(user_id, current_user_id)
      if request.method == 'PUT'
        user_id == current_user_id
      elsif request.method == 'DELETE'
        user_id == current_user_id
      end
    end

    def serialize_user_data(user)
      UserSerializer.serialize_user(user).merge(
        tasks: TaskSerializer.serialize_tasks_collection(user.tasks.order('tasks.id DESC')),
        liked_tasks: TaskSerializer.serialize_tasks_collection(user.like_tasks.order('likes.id DESC'))
      )
    end

    def update_user(user)
      if user.update(params_user_update)
        render json: user, status: :ok
      else
        render_unprocessable_entity(user)
      end
    end
  end
end
