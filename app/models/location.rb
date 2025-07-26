class Location < ApplicationRecord
  has_many :availabilities, as: :available_for
  has_many :lessons, dependent: :restrict_with_error
  has_many :booking_requests, dependent: :destroy
  has_many :lesson_series, dependent: :destroy

  validates :name, presence: true
  validates :rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def available_at?(datetime, duration_minutes = 45)
    return false unless datetime.present?
    
    end_time = datetime + duration_minutes.minutes
    
    # Check availability slots
    matching_availability = availabilities.where(
      available: true
    ).find do |avail|
      avail.start_time <= datetime && avail.end_time >= end_time
    end
    
    matching_availability.present?
  end

  def lessons_for_period(start_date, end_date)
    lessons.for_date_range(start_date, end_date)
  end

  def utilization_for_period(start_date, end_date)
    total_availability_hours = availabilities
      .for_date_range(start_date, end_date)
      .sum { |a| a.duration_minutes / 60.0 }
      
    total_lesson_hours = lessons_for_period(start_date, end_date)
      .where(status: ['completed', 'attended', 'scheduled', 'confirmed'])
      .sum(:duration) / 60.0
      
    return 0 if total_availability_hours == 0
    (total_lesson_hours / total_availability_hours * 100).round(1)
  end
end
