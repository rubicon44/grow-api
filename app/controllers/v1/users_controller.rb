# frozen_string_literal: true

module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false
    def show
      user = find_user_by_username
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
      user = find_user_by_username
      return render_not_found('User') if user.nil?

      followings = user.followings.includes(:active_relationships,
                                            :passive_relationships).order('relationships.id DESC')
      render json: { followings: UserSerializer.serialize_users_collection(followings) }, status: :ok
    end

    def followers
      user = find_user_by_username
      return render_not_found('User') if user.nil?

      followers = user.followers.includes(:active_relationships, :passive_relationships).order('relationships.id DESC')
      render json: { followers: UserSerializer.serialize_users_collection(followers) }, status: :ok
    end

    def create
      user = User.new(params_user_create)

      return render_no_content if User.exists?(firebase_id: user.firebase_id)

      if [user.nickname, user.username, user.email, user.firebase_id].any?(&:nil?)
        return render_unprocessable('A part of param')
      end

      user.save ? render_no_content : render_unprocessable_entity(user)
    end

    def update
      user = find_user_by_username
      return render_not_found('User') unless user

      current_user_id = params[:current_user_id].to_i
      method = request.method.downcase
      return render_forbidden("You are not authorized to #{method} this user") unless require_user_authorization(
        user.id, current_user_id
      )

      render json: user, status: :ok if user.update(params_user_update)
    end

    def upload_avatar
      avatar_file = params[:file]
      return render_not_found('avatar_file') unless avatar_file

      avatar_url = S3Uploader.upload_avatar_url_to_s3(avatar_file) if avatar_file.present?
      return render_not_found('avatar_url') unless avatar_url

      current_user = find_user_by_username
      return render_not_found('User') unless current_user

      render json: avatar_url, status: :ok if current_user.update(avatar_url: avatar_url)
    end

    # TODO: 追加予定
    # def destroy

    private

    def params_user_create
      params.require(:user).permit(:nickname, :username, :email, :firebase_id)
    end

    def params_user_update
      params.require(:user).permit(:nickname, :username, :bio, :avatar_url)
    end

    def find_user_by_username
      User.includes(:tasks, :likes).find_by(username: params[:username])
    end

    def require_user_authorization(user_id, current_user_id)
      if request.method == 'PUT'
        user_id == current_user_id
      elsif request.method == 'DELETE'
        user_id == current_user_id
      end
    end

    def add_tasks_and_liked_tasks(serialized_user, user, page, page_size)
      tasks = User.fetch_tasks(user, page, page_size)
      liked_tasks = User.fetch_liked_tasks(user, page, page_size)

      serialized_user.merge(
        tasks: TaskSerializer.serialize_tasks_collection(tasks),
        liked_tasks: TaskSerializer.serialize_tasks_collection(liked_tasks)
      )
    end

    def add_tasks(serialized_user, user, page, page_size)
      tasks = User.fetch_tasks(user, page, page_size)

      serialized_user.merge(
        tasks: TaskSerializer.serialize_tasks_collection(tasks)
      )
    end

    def add_liked_tasks(serialized_user, user, page, page_size)
      liked_tasks = User.fetch_liked_tasks(user, page, page_size)

      serialized_user.merge(
        liked_tasks: TaskSerializer.serialize_tasks_collection(liked_tasks)
      )
    end
  end
end
