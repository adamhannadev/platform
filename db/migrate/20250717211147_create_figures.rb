class CreateFigures < ActiveRecord::Migration[7.2]
  def change
    create_table :figures do |t|
      t.string :name
      t.string :dance
      t.string :number
      t.integer :bars
      t.text :components
      t.boolean :core

      t.timestamps
    end
  end
end
