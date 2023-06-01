# frozen_string_literal: true

class Notification < ApplicationRecord
  default_scope -> { order(created_at: :desc) }

  belongs_to :task, optional: true
  belongs_to :visitor, class_name: 'User', optional: true
  belongs_to :visited, class_name: 'User', optional: true

  validate :validate_notification

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

  private

  def validate_notification
    validate_visitor_id
    validate_visited_id
    validate_action
    validate_checked
  end

  def validate_visitor_id
    errors.add(:visitor_id, ' must be present') if visitor_id.blank?
  end

  def validate_visited_id
    errors.add(:visited_id, ' must be present') if visited_id.blank?
  end

  def validate_action
    errors.add(:action, ' must be present') if action.blank?
  end

  def validate_checked
    errors.add(:checked, ' must be either true or false') unless [true, false].include?(checked)
  end
end
