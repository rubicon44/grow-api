module V1
  class RelationshipsController < ApiController
    def create
      current_user = User.find(params[:following_id])
      user = User.find(params[:follower_id])
      current_user.follow(user)

      noti_user = User.find(params[:follower_id])
      noti_user.create_notification_follow!(current_user, noti_user)

      render json: {}, status: 201
    end

    def destroy
      current_user = User.find(params[:following_id])
      user = User.find(params[:follower_id])
      current_user.unfollow(user)
      head :no_content, status: 204
    end
  end
end