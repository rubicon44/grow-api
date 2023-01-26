class AddColumnForeignKeyToAllTables < ActiveRecord::Migration[6.0]
  def change
    remove_column :relationships, :following_id, :bigint
    remove_column :relationships, :follower_id, :bigint
    remove_column :notifications, :visitor_id, :bigint
    remove_column :notifications, :visited_id, :bigint

    add_reference :relationships, :following, foreign_key: { to_table: :users }
    add_reference :relationships, :follower, foreign_key: { to_table: :users }
    add_reference :notifications, :visitor, foreign_key: { to_table: :users }
    add_reference :notifications, :visited, foreign_key: { to_table: :users }
  end
  add_foreign_key :tasks, :users

  add_foreign_key :likes, :tasks
  add_foreign_key :likes, :users

  add_foreign_key :notifications, :tasks
end
