class Availability < ApplicationRecord
  belongs_to :available_for, polymorphic: true
  belongs_to :parent_availability, class_name: 'Availability', optional: true
  has_many :child_availabilities, class_name: 'Availability', 
           foreign_key: 'parent_availability_id', dependent: :destroy
  has_many :lessons, dependent: :nullify

  validates :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  scope :recurring_parents, -> { where(is_recurring: true, parent_availability: nil) }
  scope :individual_instances, -> { where(is_recurring: false) }
  scope :available_slots, -> { where(available: true) }
  scope :for_date_range, ->(start_date, end_date) { 
    where(start_time: start_date.beginning_of_day..end_date.end_of_day) 
  }

  def duration_minutes
    return 0 unless start_time && end_time
    ((end_time - start_time) / 1.minute).to_i
  end

  def overlaps_with?(other_start, other_end)
    start_time < other_end && end_time > other_start
  end

  def can_book_lesson?(lesson_duration_minutes = 45)
    return false unless available?
    duration_minutes >= lesson_duration_minutes
  end

  def generate_recurring_instances!
    return unless is_recurring? && recurrence_end_date.present?
    
    transaction do
      current_date = start_time.to_date
      
      while current_date <= recurrence_end_date
        # Skip the original instance
        unless current_date == start_time.to_date
          child_availabilities.create!(
            available_for: available_for,
            start_time: current_date.beginning_of_day + 
                        start_time.hour.hours + 
                        start_time.min.minutes,
            end_time: current_date.beginning_of_day + 
                      end_time.hour.hours + 
                      end_time.min.minutes,
            available: available,
            instance_date: current_date,
            is_recurring: false
          )
        end
        
        current_date += 1.week
      end
    end
  end

  def is_recurring_instance?
    parent_availability.present?
  end

  def master_availability
    parent_availability || self
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
