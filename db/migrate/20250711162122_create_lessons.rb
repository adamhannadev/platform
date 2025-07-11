class CreateLessons < ActiveRecord::Migration[7.2]
  def change
    create_table :lessons do |t|
      t.datetime :lesson_time
      t.references :student, null: false, foreign_key: true
      t.references :teacher, null: false, foreign_key: true
      t.text :plan

      t.timestamps
    end
  end
end
