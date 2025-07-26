class AddFieldsToLessons < ActiveRecord::Migration[7.2]
  def change
    add_column :lessons, :status, :string, null: false, default: 'scheduled'
    add_column :lessons, :lesson_type, :string, null: false, default: 'private'
    add_reference :lessons, :availability, null: true, foreign_key: true
    add_reference :lessons, :booking_request, null: true, foreign_key: true
    add_column :lessons, :cancelled_at, :datetime
    add_column :lessons, :cancellation_reason, :text
    add_column :lessons, :rate_charged, :decimal, precision: 8, scale: 2
    add_column :lessons, :teacher_pay, :decimal, precision: 8, scale: 2

    add_index :lessons, [:teacher_id, :start_time]
    add_index :lessons, [:student_id, :start_time] 
    add_index :lessons, :status
  end
end
