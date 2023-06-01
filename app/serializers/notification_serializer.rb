# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :task_id, :visited_id, :visitor_id, :action, :checked

  def self.serialize_notifications_collection(collection, options = {})
    ActiveModel::Serializer::CollectionSerializer.new(collection, each_serializer: NotificationSerializer,
                                                                  **options).as_json
  end
end
