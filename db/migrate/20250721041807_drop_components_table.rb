class DropComponentsTable < ActiveRecord::Migration[7.2]
  def change
      drop_table :components
  end
end
