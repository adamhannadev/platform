class CreateLessonSeries < ActiveRecord::Migration[7.2]
  def change
    create_table :lesson_series do |t|
      t.string :title, null: false
      t.references :teacher, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.references :location, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :day_of_week, null: false # 0 = Sunday, 1 = Monday, etc.
      t.time :time_of_day, null: false
      t.integer :duration, null: false, default: 45
      t.string :status, null: false, default: 'active'
      t.text :notes
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :lesson_series, [:teacher_id, :day_of_week, :time_of_day]
    add_index :lesson_series, [:student_id, :status]
    add_index :lesson_series, :status
  end
end
