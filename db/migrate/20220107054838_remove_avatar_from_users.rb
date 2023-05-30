# frozen_string_literal: true

class RemoveAvatarFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :avatar, :string
    remove_column :users, :email, :string
    remove_column :users, :firebase_id, :string
    remove_column :users, :password_digest, :string
    remove_column :users, :profile, :text
  end
end
