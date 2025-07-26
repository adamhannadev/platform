class AddRecurringToAvailabilities < ActiveRecord::Migration[7.2]
  def change
    add_column :availabilities, :is_recurring, :boolean, default: false
    add_reference :availabilities, :parent_availability, null: true, foreign_key: { to_table: :availabilities }
    add_column :availabilities, :recurrence_end_date, :date
    add_column :availabilities, :instance_date, :date # For individual instances of recurring availability

    add_index :availabilities, [:parent_availability_id, :instance_date]
    add_index :availabilities, :is_recurring
  end
end
