class RelationshipsController < ApplicationController
  # protect_from_forgery except: :create
  skip_before_action :check_authenticate!, only: %i(create), raise: false

  def create
    @user = User.find(params[:follower_id])
    @current_user = User.find(params[:following_id])
    @current_user.follow(@user)
    render json: @user, status: 201

    # @user = User.find(params[:user_id])
    # @user.create_notification_follow!(current_user)
  end

  def destroy
    @user = User.find(params[:follower_id])
    @current_user = User.find(params[:following_id])
    @current_user.unfollow(@user)
    render json: @user, status: 201
  end
end
