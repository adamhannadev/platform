class AddRatesToTeachers < ActiveRecord::Migration[7.2]
  def change
    add_column :teachers, :hourly_rate, :decimal, precision: 8, scale: 2, null: false, default: 0.0
    add_column :teachers, :student_rate, :decimal, precision: 8, scale: 2, null: false, default: 0.0
  end
end
