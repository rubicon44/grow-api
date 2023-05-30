# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :avatar
      t.string :email
      t.string :firebase_id
      t.string :name
      t.string :password_digest
      t.text :profile

      t.timestamps
    end
  end
end
