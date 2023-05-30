# frozen_string_literal: true

module V1
  class RelationshipsController < ApiController
    def create
      following_id = params[:following_id].to_i
      follower_id = params[:follower_id].to_i

      if following_id == follower_id
        render json: { errors: 'You cannot follow yourself.' }, status: :unprocessable_entity
        return
      end

      if Relationship.exists?(following_id: following_id, follower_id: follower_id)
        render json: { errors: 'You are already following this user.' }, status: :conflict
        return
      end

      current_user = User.find(params[:following_id])
      user = User.find(params[:follower_id])
      current_user.follow(user)

      noti_user = User.find(params[:follower_id])
      noti_user.create_notification_follow!(current_user, noti_user)

      render json: {}, status: :no_content
    end

    def destroy
      following_id = params[:following_id].to_i
      follower_id = params[:follower_id].to_i

      if following_id == follower_id
        render json: { errors: 'You cannot unfollow yourself.' }, status: :unprocessable_entity
        return
      end

      following_user = User.find_by(id: following_id)
      follower_user = User.find_by(id: follower_id)

      if following_user.nil?
        render json: { errors: "Couldn't find User with 'id'=#{following_id}" }, status: :not_found
        return
      end

      if follower_user.nil?
        render json: { errors: "Couldn't find User with 'id'=#{follower_id}" }, status: :not_found
        return
      end

      if Relationship.where(following_id: following_id, follower_id: follower_id).empty?
        render json: { errors: 'You are not unfollowing this user.' }, status: :conflict
        return
      end

      current_user = User.find(params[:following_id])
      user = User.find(params[:follower_id])
      current_user.unfollow(user)
      head :no_content, status: 204
    end
  end
end
