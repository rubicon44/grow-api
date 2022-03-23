class RenameColumnBioToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :profile, :bio
  end
end
