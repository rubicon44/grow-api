# frozen_string_literal: true

class Notification < ApplicationRecord
  default_scope -> { order(created_at: :desc) }

  belongs_to :task, optional: true
  belongs_to :visitor, class_name: 'User', optional: true
  belongs_to :visited, class_name: 'User', optional: true

  validates :visitor_id, presence: true
  validates :visited_id, presence: true
  validates :action, presence: true
  validates :checked, inclusion: { in: [true, false] }

  def self.mark_notifications_as_read(user)
    user.passive_notifications.where(checked: false).find_each do |notification|
      notification.update(checked: true)
    end
  end

  def self.get_unread_notifications(user)
    user.passive_notifications.where.not(visitor_id: user.id)
  end

  def self.generate_notification_users(user)
    follow_visitors = user.passive_notifications.select { |n| n.action == 'follow' }.map(&:visitor)
    like_visitors = user.passive_notifications.select do |n|
      n.action == 'like' && n.visitor_id != user.id
    end.map(&:visitor)

    [follow_visitors.uniq, like_visitors.uniq]
  end
end
