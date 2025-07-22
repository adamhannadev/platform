class AddUserIdToTeachers < ActiveRecord::Migration[7.2]
  def change
    add_column :teachers, :user_id, :integer, null: true
  end
end
