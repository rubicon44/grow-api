class User < ApplicationRecord
  # include ActiveModel::Serializers::JSON
  has_many :tasks
  has_many :likes, dependent: :destroy
  has_many :like_tasks, through: :likes, source: :task

  def already_liked?(task)
    likes.exists?(task_id: task.id)
  end

  def like(task)
    likes.create(task_id: task.id)
  end

  def unlike(task)
    likes.find_by(task_id: task.id).destroy
  end
end
