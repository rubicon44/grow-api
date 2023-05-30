# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user_id, presence: true
  validates :task_id, presence: true

  def self.create_like_and_notification(current_user, task)
    current_user.like(task)
    noti_task = Task.find(task.id)
    noti_task.create_notification_like!(current_user)
  end

  def self.user_already_liked?(current_user, task)
    current_user.likes.exists?(task_id: task.id)
  end
end
