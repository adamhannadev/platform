class AddDurationToLessons < ActiveRecord::Migration[7.2]
  def change
    add_column :lessons, :duration, :integer, default: 45, null: false
  end
end
