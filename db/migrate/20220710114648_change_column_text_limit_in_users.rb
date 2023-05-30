# frozen_string_literal: true

class ChangeColumnTextLimitInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column :users, :nickname, :string, limit: 50
    change_column :users, :bio, :string, limit: 160
    change_column :users, :username, :string, limit: 15
  end
end
