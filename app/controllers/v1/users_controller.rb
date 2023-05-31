# frozen_string_literal: true

module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i[create], raise: false
    def show
      user = User.find_by(username: params[:username])

      if user.nil?
        render_user_not_found
      else
        user_data = serialize_user(user).merge(
          tasks: serialize_collection(user.tasks.order('tasks.id DESC'), TaskSerializer, user: true),
          liked_tasks: serialize_collection(user.like_tasks.order('likes.id DESC'), TaskSerializer, user: true)
        )
        render json: user_data, status: :ok
      end
    end

    def followings
      user = User.find_by(username: params[:username])

      if user.nil?
        render_user_not_found
      else
        followings = user.followings.order('relationships.id DESC')
        render json: { followings: serialize_collection(followings, UserSerializer) }, status: :ok
      end
    end

    def followers
      user = User.find_by(username: params[:username])

      if user.nil?
        render_user_not_found
      else
        followers = user.followers.order('relationships.id DESC')
        render json: { followers: serialize_collection(followers, UserSerializer) }, status: :ok
      end
    end

    def create
      user = User.new(params_user_create)
      if [user.nickname, user.username, user.email, user.firebase_id].any?(&:nil?)
        return render_unprocessable_entity(user)
      end

      render_no_content if user.save
    end

    def update
      user = User.find_by(username: params[:username])
      return render_user_not_found if user.nil?

      current_user_id = params[:current_user_id].to_i
      return render_forbidden(request.method.downcase) unless require_user_authorization(user.id, current_user_id)

      render_no_content if user.update(params_user_update)
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

    # TODO: serializerへ移動
    def serialize_collection(collection, serializer, options = {})
      ActiveModel::Serializer::CollectionSerializer.new(collection, each_serializer: serializer, **options)
    end

    def serialize_user(user)
      UserSerializer.new(user).as_json
    end

    # TODO: エラー出力の方法をapi_controllerに任せるか検討
    def render_forbidden(method)
      render json: { errors: "You are not authorized to #{method} this user" }, status: :forbidden
    end

    def render_no_content
      render json: {}, status: :no_content
    end

    def render_unprocessable_entity(object)
      render json: { errors: object.errors.full_messages }, status: :unprocessable_entity
    end

    def render_user_not_found
      render json: { errors: 'User not found' }, status: :not_found
    end
  end
end
