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
    availabilities = Availability.where(
      available_for: resource,
      available_on: start_time.to_date,
      available: true
    )

    lesson_time = start_time.strftime("%H:%M")
    availabilities.any? do |a|
      a.start_time.strftime("%H:%M") <= lesson_time && a.end_time.strftime("%H:%M") > lesson_time
    end
  end
end
