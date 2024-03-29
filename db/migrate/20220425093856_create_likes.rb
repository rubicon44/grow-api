# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[6.0]
  def change
    create_table :likes do |t|
      t.integer :task_id
      t.integer :user_id

      t.timestamps
    end
  end
end
