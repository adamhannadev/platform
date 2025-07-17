class AddLevelToFigures < ActiveRecord::Migration[7.2]
  def change
    add_column :figures, :level, :string
  end
end
