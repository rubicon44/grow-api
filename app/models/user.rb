# frozen_string_literal: true

class User < ApplicationRecord
  validates :username, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, message: 'は有効なメールアドレスの形式で入力してください' }

  has_many :tasks
  has_many :likes, dependent: :destroy
  has_many :like_tasks, through: :likes, source: :task

  has_many :active_relationships, class_name: 'Relationship', foreign_key: :following_id, dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: :follower_id, dependent: :destroy
  has_many :followings, through: :active_relationships, source: :follower
  has_many :followers, through: :passive_relationships, source: :following

  has_many :active_notifications, class_name: 'Notification', foreign_key: 'visitor_id', dependent: :destroy
  has_many :passive_notifications, class_name: 'Notification', foreign_key: 'visited_id', dependent: :destroy
  has_many :visitors, through: :active_notifications, source: :visitor
  has_many :visiteds, through: :passive_notifications, source: :visited

  # like function
  def like(task)
    likes.create(task_id: task.id)
  end

  def unlike(task)
    likes.find_by(task_id: task.id).destroy
  end

  # follow function
  def follow(user)
    active_relationships.create(follower_id: user.id)
  end

  def unfollow(user)
    active_relationships.find_by(follower_id: user.id).destroy
  end

  def create_notification_follow!(following_user, follower_user)
    return if Notification.where(visitor_id: following_user.id, visited_id: follower_user.id, action: 'follow').present?

    notification = following_user.active_notifications.new(
      visited_id: follower_user.id,
      visitor_id: following_user.id,
      action: 'follow'
    )
    notification.save if notification.valid?
  end
end
