# frozen_string_literal: true

class AddColumnFirebaseIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :firebase_id, :string
    add_column :users, :password_digest, :string
  end
end
