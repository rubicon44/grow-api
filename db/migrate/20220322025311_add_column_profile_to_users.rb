# frozen_string_literal: true

class AddColumnProfileToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :profile, :text
  end
end
