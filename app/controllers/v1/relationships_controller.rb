# frozen_string_literal: true

module V1
  class RelationshipsController < ApiController
    # TODO: 「Max: 11」適用
    def create
      following_id = params[:following_id].to_i
      follower_id = params[:follower_id].to_i
      return render_user_not_follow_error('You cannot follow yourself.') if following_id == follower_id

      following_user, follower_user = Relationship.find_following_and_follower_users(following_id, follower_id)
      return render_user_not_found_error(following_id) if following_user.nil?
      return render_user_not_found_error(follower_id) if follower_user.nil?
      return render_user_follow_conflict_error('Already following this user.') if Relationship.relationship_exists?(
        following_id, follower_id
      )

      Relationship.follow_users(following_id, follower_id)
      render_no_content
    end

    # TODO: 「Max: 11」適用
    def destroy
      following_id = params[:following_id].to_i
      follower_id = params[:follower_id].to_i
      return render_user_not_follow_error('You cannot unfollow yourself.') if following_id == follower_id

      following_user, follower_user = Relationship.find_following_and_follower_users(following_id, follower_id)
      return render_user_not_found_error(following_id) if following_user.nil?
      return render_user_not_found_error(follower_id) if follower_user.nil?
      return render_user_follow_conflict_error('Not unfollowing this user.') if Relationship.relationship_not_found?(
        following_id, follower_id
      )

      Relationship.unfollow_users(following_id, follower_id)
      render_no_content
    end

    private

    def render_no_content
      render json: {}, status: :no_content
    end

    def render_user_not_follow_error(message)
      render json: { errors: message }, status: :unprocessable_entity
    end

    def render_user_follow_conflict_error(message)
      render json: { errors: message }, status: :conflict
    end

    def render_user_not_found_error(user_id)
      render json: { errors: "Couldn't find User with 'id'=#{user_id}" }, status: :not_found
    end
  end
end
