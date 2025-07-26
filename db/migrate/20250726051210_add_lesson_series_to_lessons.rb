class AddLessonSeriesToLessons < ActiveRecord::Migration[7.2]
  def change
    add_reference :lessons, :lesson_series, null: true, foreign_key: true
    add_column :lessons, :series_instance_number, :integer
    add_column :lessons, :is_makeup_lesson, :boolean, default: false

    add_index :lessons, [:lesson_series_id, :series_instance_number]
  end
end
