# frozen_string_literal: true

class ChangeColumnUserNameToUsernameInUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :user_name, :username
  end
end
