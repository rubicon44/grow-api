class UsersController < ApplicationController
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
    @user = User.find(params[:id])
    # @like_tasks = @user.like_tasks
    @likes = Like.where(user_id: params[:id])
    @task_created_user = []
    @likes.each do |like|
      @task_created_user.push(like.task.user)
    end
    # @task_and_task_created_user = { "like_tasks" => @like_tasks, "task_created_user" => @task_created_user }
    # render json: { user: @user }, include: [:tasks, :like_tasks], status: 201
    render json: { user: @user.as_json(include: [:tasks, :like_tasks]), task_created_user: @task_created_user }, status: 201
  end

  def update
    @user = User.find(params[:id])
    if @user.update(params_user_update)
      render json: { user: @user }, status: 201
    else
      render json: {"error": @user.errors}, status: 500
    end
  end

  def followings
    user = User.find(params[:id])
    @followings = user.followings
    render json: { followings: @followings }, status: 201
  end

  def followers
    user = User.find(params[:id])
    @followers = user.followers
    render json: { followers: @followers }, status: 201
  end

  private

  def params_user_create
    params.require(:user).permit(:name, :email, :firebase_id)
  end

  def params_user_update
    params.require(:user).permit(:bio)
  end
end
