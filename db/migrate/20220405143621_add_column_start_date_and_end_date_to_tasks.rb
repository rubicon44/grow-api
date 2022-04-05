class AddColumnStartDateAndEndDateToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :start_date, :string
    add_column :tasks, :end_date, :string
  end
end
