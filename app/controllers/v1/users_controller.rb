module V1
  class UsersController < ApiController
    skip_before_action :check_authenticate!, only: %i(create), raise: false
    # skip_before_action :check_authenticate!, only: %i(followings), raise: false
    # skip_before_action :check_authenticate!, only: %i(followers), raise: false

    def index
      @user = User.all
      render json: @user
    end

    def create
      @user = User.new(params_user_create)
      if @user.save
        render json: { user: @user }, status: 201
      else
        render json: {"error": @user.errors}, status: 500
      end
    end

    def show
      @user = User.find_by(username: params[:username])
      if @user
        @liked_tasks = @user.like_tasks.order('likes.id DESC')
        liked_tasks_with_user = []
        @liked_tasks.each do |task|
          user = User.find(task.user_id)
          liked_tasks_with_user.push({task: task, user: user})
        end

        render json: { user: @user.as_json(include: [:tasks, :like_tasks]), liked_tasks_with_user: liked_tasks_with_user }, status: 201
      else
        render json: { error: "User not found" }, status: 404
      end
    end

    def update
      @user = User.find_by(username: params[:username])
      if @user.update(params_user_update)
        render json: { user: @user }, status: 201
      else
        render json: {"error": @user.errors}, status: 500
      end
    end

    def followings
      user = User.find_by(username: params[:username])
      followings = user.followings.order('relationships.id DESC')
      render json: { followings: ActiveModel::Serializer::CollectionSerializer.new(followings, each_serializer: UserSerializer) }, status: 201
    end

    def followers
      user = User.find_by(username: params[:username])
      followers = user.followers.order('relationships.id DESC')
      render json: { followers: ActiveModel::Serializer::CollectionSerializer.new(followers, each_serializer: UserSerializer) }, status: 201
    end

    private

    def params_user_create
      params.require(:user).permit(:nickname, :username, :email, :firebase_id)
    end

    def params_user_update
      params.require(:user).permit(:nickname, :username, :bio)
    end
  end
end