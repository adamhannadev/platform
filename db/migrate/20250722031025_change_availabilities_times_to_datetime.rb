class ChangeAvailabilitiesTimesToDatetime < ActiveRecord::Migration[7.2]
  def change
    remove_column :availabilities, :available_on, :date
    change_column :availabilities, :start_time, :datetime
    change_column :availabilities, :end_time, :datetime
  end
end
