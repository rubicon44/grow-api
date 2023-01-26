class ChangeColumnNotNullInAllTables < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :nickname, false
    change_column_null :users, :email, false
    change_column_null :users, :firebase_id, false
    change_column_null :users, :username, false

    change_column_null :tasks, :user_id, false
    change_column_null :tasks, :status, false
    change_column_null :tasks, :start_date, false
    change_column_null :tasks, :end_date, false

    change_column_null :likes, :task_id, false
    change_column_null :likes, :user_id, false

    change_column_null :relationships, :following_id, false
    change_column_null :relationships, :follower_id, false

    change_column_null :notifications, :task_id, false
  end
end
