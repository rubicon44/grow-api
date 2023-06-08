# frozen_string_literal: true

module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false
    def show
      user = find_user
      return render_not_found('User') if user.nil?

      page = params[:page].to_i
      page_size = params[:page_size].to_i

      data_type = params[:data_type]
      serialized_user = UserSerializer.serialize_user(user)

      serialized_user = add_tasks_and_liked_tasks(serialized_user, user, page, page_size) if data_type == 'default'
      serialized_user = add_tasks(serialized_user, user, page, page_size) if data_type == 'tasks'
      serialized_user = add_liked_tasks(serialized_user, user, page, page_size) if data_type == 'likedTasks'

      render json: serialized_user, status: :ok
    end

    def followings
      user = find_user
      return render_not_found('User') if user.nil?

      followings = user.followings.includes(:active_relationships,
                                            :passive_relationships).order('relationships.id DESC')
      render json: { followings: UserSerializer.serialize_users_collection(followings) }, status: :ok
    end

    def followers
      user = find_user
      return render_not_found('User') if user.nil?

      followers = user.followers.includes(:active_relationships, :passive_relationships).order('relationships.id DESC')
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

    def add_tasks_and_liked_tasks(serialized_user, user, page, page_size)
      tasks = fetch_tasks(user, page, page_size)
      liked_tasks = fetch_liked_tasks(user, page, page_size)

      serialized_user.merge(
        tasks: TaskSerializer.serialize_tasks_collection(tasks),
        liked_tasks: TaskSerializer.serialize_tasks_collection(liked_tasks)
      )
    end

    def add_tasks(serialized_user, user, page, page_size)
      tasks = fetch_tasks(user, page, page_size)

      serialized_user.merge(
        tasks: TaskSerializer.serialize_tasks_collection(tasks)
      )
    end

    def add_liked_tasks(serialized_user, user, page, page_size)
      liked_tasks = fetch_liked_tasks(user, page, page_size)

      serialized_user.merge(
        liked_tasks: TaskSerializer.serialize_tasks_collection(liked_tasks)
      )
    end

    def fetch_tasks(user, page, page_size)
      user.tasks.includes(:user)
          .order('tasks.id DESC')
          .limit(page_size)
          .offset((page - 1) * page_size)
    end

    def fetch_liked_tasks(user, page, page_size)
      user.like_tasks.includes(:user)
          .order('likes.id DESC')
          .limit(page_size)
          .offset((page - 1) * page_size)
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
