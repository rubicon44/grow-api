# frozen_string_literal: true

class AddUserIdToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :user_id, :bigint
  end
end
