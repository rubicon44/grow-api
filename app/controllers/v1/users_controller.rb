module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i(create), raise: false
    before_action :require_user_owner, only: [:update]

    # def index
    #   users = User.all
    #   users_data = ActiveModel::Serializer::CollectionSerializer.new(users, each_serializer: UserSerializer)
    #   render json: { users: users_data }, status: 200
    # end

    def show
      user = User.find_by(username: params[:username])
      user_data = UserSerializer.new(user).as_json
      user_data[:tasks] = ActiveModel::Serializer::CollectionSerializer.new(user.tasks.order('tasks.id DESC'), each_serializer: TaskSerializer)
      user_data[:liked_tasks] = ActiveModel::Serializer::CollectionSerializer.new(user.like_tasks.order('likes.id DESC'), each_serializer: TaskSerializer)
      render json: user_data, status: 200
    end

    def followings
      user = User.find_by(username: params[:username])
      followings = user.followings.order('relationships.id DESC')
      render json: { followings: ActiveModel::Serializer::CollectionSerializer.new(followings, each_serializer: UserSerializer) }, status: 200
    end

    def followers
      user = User.find_by(username: params[:username])
      followers = user.followers.order('relationships.id DESC')
      render json: { followers: ActiveModel::Serializer::CollectionSerializer.new(followers, each_serializer: UserSerializer) }, status: 200
    end

    def create
      user = User.new(params_user_create)
      render json: {}, status: 204 if user.save
    end

    def update
      user = User.find_by(username: params[:username])
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

    def require_user_owner
      user = User.find_by(username: params[:username])
      current_user_id = params[:current_user_id]
      unless user.id == current_user_id
        render json: { errors: "You are not authorized to update this user" }, status: :forbidden
      end
    end
  end
end