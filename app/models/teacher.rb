class Teacher < ApplicationRecord
    has_many :lessons, dependent: :destroy
    has_many :availabilities, as: :available_for
    has_many :booking_requests, dependent: :destroy
    has_many :lesson_series, dependent: :destroy
    belongs_to :user, optional: true

    accepts_nested_attributes_for :user

    validates :first_name, :last_name, presence: true
    validates :hourly_rate, :student_rate, presence: true, 
              numericality: { greater_than_or_equal_to: 0 }

    def full_name
        "#{first_name} #{last_name}".strip
    end

    def name
        full_name
    end

    def lessons_for_period(start_date, end_date)
        lessons.for_date_range(start_date, end_date)
    end

    def total_earnings_for_period(start_date, end_date)
        lessons_for_period(start_date, end_date)
          .where(status: ['completed', 'attended'])
          .sum(:teacher_pay)
    end

    def total_lessons_taught_for_period(start_date, end_date)
        lessons_for_period(start_date, end_date)
          .where(status: ['completed', 'attended'])
          .count
    end

    def available_at?(datetime, duration_minutes = 45)
        return false unless datetime.present?
        
        end_time = datetime + duration_minutes.minutes
        
        # Check for conflicting lessons
        conflicting_lessons = lessons.where(
          status: ['scheduled', 'confirmed'],
          start_time: (datetime - duration_minutes.minutes)..(datetime + duration_minutes.minutes)
        )
        
        return false if conflicting_lessons.any?
        
        # Check availability slots
        day_of_week = datetime.wday
        time_of_day = datetime.strftime('%H:%M:%S')
        
        matching_availability = availabilities.where(
          available: true
        ).find do |avail|
          avail.start_time <= datetime && avail.end_time >= end_time
        end
        
        matching_availability.present?
    end
end
