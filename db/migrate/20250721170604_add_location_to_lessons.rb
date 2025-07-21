class AddLocationToLessons < ActiveRecord::Migration[7.2]
  def change
    add_reference :lessons, :location, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        # Replace 1 with the ID of a real location in your DB
        default_location_id = Location.first&.id || Location.create!(name: "Default", address: "TBD", rate: 0).id
        Lesson.update_all(location_id: default_location_id)
      end
    end

    change_column_null :lessons, :location_id, false
  end
end
