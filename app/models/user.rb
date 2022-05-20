class User < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  has_many :tasks
  has_many :likes, dependent: :destroy
  has_many :like_tasks, through: :likes, source: :task

  has_many :active_relationships, class_name: 'Relationship', foreign_key: :following_id, dependent: :destroy
  has_many :followings, through: :active_relationships, source: :follower
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: :follower_id, dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :following

  has_many :active_notifications, class_name: 'Notification', foreign_key: 'visitor_id', dependent: :destroy,
  inverse_of: 'visitor'
  has_many :passive_notifications, class_name: 'Notification', foreign_key: 'visited_id', dependent: :destroy

  # like function
  def already_liked?(task)
    likes.exists?(task_id: task.id)
  end

  def like(task)
    likes.create(task_id: task.id)
  end

  def unlike(task)
    likes.find_by(task_id: task.id).destroy
  end

  # follow function
  def already_followed?(user)
    passive_relationships.find_by(following_id: user.id).present?
  end

  def follow(user)
    active_relationships.create(follower_id: user.id)
  end

  def unfollow(user)
    active_relationships.find_by(follower_id: user.id).destroy
  end

  def create_notification_follow!(current_user)
    temp = Notification.where(['visitor_id = ? and visited_id = ? and action = ? ', current_user.id, id, 'follow'])
    return unless temp.blank?

    notification = current_user.active_notifications.new(
      visited_id: id,
      action: 'follow'
    )
    notification.save if notification.valid?
  end
end
