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
end
