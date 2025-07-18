class AddDetailsToCharts < ActiveRecord::Migration[7.2]
  def change
    add_column :charts, :movement, :text
    add_column :charts, :timing, :string
    add_column :charts, :partnering, :text
  end
end
