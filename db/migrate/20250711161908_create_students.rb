class CreateStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :students do |t|
      t.string :last_name
      t.string :first_name
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
