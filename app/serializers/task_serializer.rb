# frozen_string_literal: true

class TaskSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :content, :end_date, :start_date, :status, :title
  belongs_to :user

  def self.serialize_tasks_collection(collection, options = {})
    ActiveModel::Serializer::CollectionSerializer.new(collection, each_serializer: TaskSerializer, **options).as_json
  end

  def self.serialize_task(task)
    TaskSerializer.new(task).as_json
  end

  def self.serialize_user(user)
    UserSerializer.new(user).as_json
  end
end
