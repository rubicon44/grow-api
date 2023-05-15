class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :task_id, :visited_id, :visitor_id, :action, :checked
end