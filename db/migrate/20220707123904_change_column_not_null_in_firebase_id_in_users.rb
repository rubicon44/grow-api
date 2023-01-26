class ChangeColumnNotNullInFirebaseIdInUsers < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :firebase_id, true
  end
end
