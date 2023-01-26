class ChangeDataTypesIntegerToBigintInAllIdColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :user_id, :bigint

    change_column :likes, :task_id, :bigint
    change_column :likes, :user_id, :bigint

    change_column :relationships, :following_id, :bigint
    change_column :relationships, :follower_id, :bigint

    change_column :notifications, :visitor_id, :bigint
    change_column :notifications, :visited_id, :bigint
    change_column :notifications, :task_id, :bigint
  end
end
