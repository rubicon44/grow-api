# frozen_string_literal: true

class SearchSerializer < ActiveModel::Serializer
  attribute :users, if: -> { object.users.present? }
  attribute :tasks, if: -> { object.tasks.present? }
  attribute :task_users, if: -> { object.task_users.present? }
end
