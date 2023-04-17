module V1
  class RelationshipsController < ApiController
    # protect_from_forgery except: :create
    skip_before_action :check_authenticate!, only: %i(create), raise: false

    def create
      @user = User.find(params[:follower_id])
      @current_user = User.find(params[:following_id])
      @current_user.follow(@user)

      # follow notification(Not render this)
      @noti_user = User.find(params[:follower_id])
      @current_user = User.find(params[:following_id])
      @noti_user.create_notification_follow!(@current_user, @noti_user)
      render json: @user, status: 201
    end

    def destroy
      @user = User.find(params[:follower_id])
      @current_user = User.find(params[:following_id])
      @current_user.unfollow(@user)
      render json: @user, status: 201
    end
  end
end