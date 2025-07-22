class Lesson < ApplicationRecord
  belongs_to :student
  belongs_to :teacher
  belongs_to :location

  validate :start_time_within_teacher_and_location_availability

  private

  def start_time_within_teacher_and_location_availability
    unless available_for?(teacher) && available_for?(location)
      errors.add(:start_time, "must be within the availabilities of both the teacher and location")
    end
  end

  def available_for?(resource)
    Availability.where(
      available_for_type: resource.class.name,
      available_for_id: resource.id,
      available: true
    ).where(
      "start_time <= ? AND end_time > ?", start_time.in_time_zone("Pacific Time (US & Canada)"), start_time.in_time_zone("Pacific Time (US & Canada)")
    ).exists?
  end
end
