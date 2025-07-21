class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.date :available_on
      t.time :start_time
      t.time :end_time
      t.boolean :available
      t.references :available_for, polymorphic: true, null: false

      t.timestamps
    end
  end
end
