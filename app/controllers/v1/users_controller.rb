# frozen_string_literal: true

module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false

    # def index
    #   users = User.all
    #   users_data = ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer)
    #   render json: { users: users_data }, status: 200
    # end

    def show
      user = User.find_by(username: params[:username])

      # TODO: エラー出力の方法をapi_controllerに任せるか検討
      if user.nil?
        render json: { errors: 'User not found' }, status: :not_found
      else
        user_data = UserSerializer.new(user).as_json
        user_data[:tasks] =
          ActiveModel::Serializer::CollectionSerializer.new(user.tasks.order('tasks.id DESC'), each_serializer: TaskSerializer,
                                                                                               user: true)
        user_data[:liked_tasks] =
          ActiveModel::Serializer::CollectionSerializer.new(user.like_tasks.order('likes.id DESC'),
                                                            each_serializer: TaskSerializer, user: true)
        render json: user_data, status: :ok
      end
    end

    def followings
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { error: 'User not found' }, status: :not_found
      else
        followings = user.followings.order('relationships.id DESC')
        render json: { followings: ActiveModel::Serializer::CollectionSerializer.new(followings, each_serializer: UserSerializer) },
               status: :ok
      end
    end

    def followers
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { error: 'User not found' }, status: :not_found
      else
        followers = user.followers.order('relationships.id DESC')
        render json: { followers: ActiveModel::Serializer::CollectionSerializer.new(followers, each_serializer: UserSerializer) },
               status: :ok
      end
    end

    def create
      user = User.new(params_user_create)

      if user.nickname.nil? || user.username.nil? || user.email.nil? || user.firebase_id.nil?
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        return
      end

      render json: {}, status: :no_content if user.save
    end

    def update
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { errors: 'User not found' }, status: :not_found
        return
      end

      current_user_id = params[:current_user_id].to_i
      unless require_user_authorization(user.id, current_user_id)
        render json: { errors: "You are not authorized to #{request.method.downcase} this user" }, status: :forbidden
        return
      end

      render json: {}, status: :no_content if user.update(params_user_update)
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

    def require_user_authorization(user_id, current_user_id)
      if request.method == 'PUT'
        user_id == current_user_id
      elsif request.method == 'DELETE'
        user_id == current_user_id
      end
    end
  end
end
