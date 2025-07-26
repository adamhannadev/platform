class CreateBookingRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :booking_requests do |t|
      t.references :student, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.datetime :requested_start_time, null: false
      t.integer :duration, null: false, default: 45
      t.string :status, null: false, default: 'pending'
      t.text :notes
      t.references :approved_by, null: true, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.text :rejection_reason

      t.timestamps
    end

    add_index :booking_requests, [:student_id, :status]
    add_index :booking_requests, [:teacher_id, :requested_start_time]
    add_index :booking_requests, :status
  end
end
