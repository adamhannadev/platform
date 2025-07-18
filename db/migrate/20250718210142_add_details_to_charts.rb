class AddDetailsToCharts < ActiveRecord::Migration[7.2]
  def change
    add_column :charts, :movement, :boolean
    add_column :charts, :timing, :boolean
    add_column :charts, :partnering, :boolean
  end
end
