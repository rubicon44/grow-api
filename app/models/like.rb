# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validate :validate_like

  def self.create_like_and_notification(current_user, task)
    current_user.like(task)
    noti_task = Task.find(task.id)
    noti_task.create_notification_like!(current_user)
  end

  def self.user_already_liked?(current_user, task)
    current_user.likes.exists?(task_id: task.id)
  end

  def self.user_owns_likes?(current_user, likes)
    likes.pluck(:user_id).include?(current_user.id)
  end

  private

  def validate_like
    validate_user_id
    validate_task_id
  end

  def validate_user_id
    errors.add(:user_id, ' must be present') if user_id.blank?
  end

  def validate_task_id
    errors.add(:task_id, ' must be present') if task_id.blank?
  end
end
