class ChangeDataUserIdToTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :tasks, :user_id, :string
  end
end
