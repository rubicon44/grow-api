# frozen_string_literal: true

class ChangeColumnNotNullInTaskIdInNotifications < ActiveRecord::Migration[6.0]
  def change
    change_column_null :notifications, :task_id, true
  end
end
