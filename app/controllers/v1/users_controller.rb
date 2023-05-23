module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i(create), raise: false

    # def index
    #   users = User.all
    #   users_data = ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer)
    #   render json: { users: users_data }, status: 200
    # end

    def show
      user = User.find_by(username: params[:username])

      # todo: エラー出力の方法をapi_controllerに任せるか検討
      if user.nil?
        render json: { errors: 'User not found' }, status: 404
      else
        user_data = UserSerializer.new(user).as_json
        user_data[:tasks] = ActiveModel::Serializer::CollectionSerializer.new(user.tasks.order('tasks.id DESC'), each_serializer: TaskSerializer)
        user_data[:liked_tasks] = ActiveModel::Serializer::CollectionSerializer.new(user.like_tasks.order('likes.id DESC'), each_serializer: TaskSerializer, user: true)
        render json: user_data, status: 200
      end
    end

    def followings
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { error: 'User not found' }, status: 404
      else
        followings = user.followings.order('relationships.id DESC')
        render json: { followings: ActiveModel::Serializer::CollectionSerializer.new(followings, each_serializer: UserSerializer) }, status: 200
      end
    end

    def followers
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { error: 'User not found' }, status: 404
      else
        followers = user.followers.order('relationships.id DESC')
        render json: { followers: ActiveModel::Serializer::CollectionSerializer.new(followers, each_serializer: UserSerializer) }, status: 200
      end
    end

    def create
      user = User.new(params_user_create)

      if user.nickname.nil? || user.username.nil? || user.email.nil? || user.firebase_id.nil?
        render json: { errors: user.errors.full_messages }, status: 422
        return
      end

      render json: {}, status: 204 if user.save
    end

    def update
      user = User.find_by(username: params[:username])

      if user.nil?
        render json: { errors: 'User not found' }, status: 404
        return
      end

      current_user_id = params[:current_user_id].to_i
      unless require_user_authorization(user.id, current_user_id)
        render json: { errors: "You are not authorized to #{request.method.downcase} this user" }, status: 403
        return
      end

      render json: {}, status: 204 if user.update(params_user_update)
    end

    # todo: 追加予定
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
        return user_id == current_user_id
      elsif request.method == 'DELETE'
        return user_id == current_user_id
      end
    end
  end
end