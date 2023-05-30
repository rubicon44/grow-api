# frozen_string_literal: true

class RenameColumnNameToNicknameInUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :name, :nickname
  end
end
