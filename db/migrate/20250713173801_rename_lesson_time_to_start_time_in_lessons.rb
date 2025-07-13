class RenameLessonTimeToStartTimeInLessons < ActiveRecord::Migration[7.2]
  def change
    rename_column :lessons, :lesson_time, :start_time
  end
end