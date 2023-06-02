# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :following, class_name: 'User', optional: true
  belongs_to :follower, class_name: 'User', optional: true

  validate :validate_relationship

  def self.find_following_and_follower_users(following_id, follower_id)
    following_user = User.find_by(id: following_id)
    follower_user = User.find_by(id: follower_id)
    [following_user, follower_user]
  end

  def self.relationship_exists?(following_id, follower_id)
    Relationship.exists?(following_id: following_id, follower_id: follower_id)
  end

  def self.follow_users(following_id, follower_id)
    following_user = User.find_by(id: following_id)
    follower_user = User.find_by(id: follower_id)
    following_user.follow(follower_user)
    create_notification_follow(following_user, follower_user)
  end

  def self.unfollow_users(following_id, follower_id)
    following_user = User.find_by(id: following_id)
    follower_user = User.find_by(id: follower_id)
    following_user.unfollow(follower_user)
  end

  def self.relationship_not_found?(following_id, follower_id)
    Relationship.where(following_id: following_id, follower_id: follower_id).empty?
  end

  def self.create_notification_follow(following_user, follower_user)
    follower_user.create_notification_follow!(following_user, follower_user)
  end

  private

  def validate_relationship
    validate_following_id
    validate_follower_id
  end

  def validate_following_id
    errors.add(:following_id, ' must be present') if following_id.blank?
  end

  def validate_follower_id
    errors.add(:follower_id, ' must be present') if follower_id.blank?
  end
end
