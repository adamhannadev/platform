class CreateCharts < ActiveRecord::Migration[7.2]
  def change
    create_table :charts do |t|
      t.references :student, null: false, foreign_key: true
      t.references :figure, null: false, foreign_key: true

      t.timestamps
    end
  end
end
