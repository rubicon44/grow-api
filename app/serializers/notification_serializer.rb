# frozen_string_literal: true

class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :task_id, :visited_id, :visitor_id, :action, :checked
end
