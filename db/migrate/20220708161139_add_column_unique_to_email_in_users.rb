# frozen_string_literal: true

class AddColumnUniqueToEmailInUsers < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :email, unique: true
  end
end
