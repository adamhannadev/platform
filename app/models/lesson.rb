class Lesson < ApplicationRecord
  belongs_to :student
  belongs_to :teacher
  belongs_to :location
  belongs_to :availability, optional: true
  belongs_to :booking_request, optional: true
  belongs_to :lesson_series, optional: true

  validates :start_time, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { 
    in: %w[scheduled confirmed attended cancelled no_show completed] 
  }
  validates :lesson_type, presence: true, inclusion: { 
    in: %w[private group trial] 
  }

  validate :start_time_within_teacher_and_location_availability
  validate :not_cancelled_too_late
  validate :no_teacher_conflicts

  scope :for_date_range, ->(start_date, end_date) { 
    where(start_time: start_date.beginning_of_day..end_date.end_of_day) 
  }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_teacher, ->(teacher) { where(teacher: teacher) }
  scope :for_student, ->(student) { where(student: student) }
  scope :recurring, -> { where.not(lesson_series: nil) }
  scope :one_time, -> { where(lesson_series: nil) }

  def end_time
    start_time + duration.minutes
  end

  def can_be_cancelled?
    return false if %w[cancelled completed attended].include?(status)
    start_time > 12.hours.from_now
  end

  def cancel!(reason = nil)
    return false unless can_be_cancelled?
    
    update!(
      status: 'cancelled',
      cancelled_at: Time.current,
      cancellation_reason: reason
    )
    
    # Free up the availability slot
    availability&.update!(available: true)
    true
  end

  def mark_completed!
    update!(status: 'completed')
  end

  def revenue
    rate_charged || teacher&.student_rate || 0
  end

  def teacher_cost
    teacher_pay || teacher&.hourly_rate || 0
  end

  def profit
    revenue - teacher_cost
  end

  private

  def start_time_within_teacher_and_location_availability
    return unless start_time.present? && teacher.present? && location.present?
    
    unless available_for?(teacher) && available_for?(location)
      errors.add(:start_time, "must be within the availabilities of both the teacher and location")
    end
  end

  def not_cancelled_too_late
    return unless cancelled_at.present? && start_time.present?
    
    if cancelled_at > (start_time - 12.hours)
      errors.add(:cancelled_at, "cannot cancel less than 12 hours before lesson")
    end
  end

  def no_teacher_conflicts
    return unless teacher.present? && start_time.present?
    
    conflicting_lessons = teacher.lessons
                                .where(status: ['scheduled', 'confirmed'])
                                .where(start_time: (start_time - duration.minutes)..(start_time + duration.minutes))
                                .where.not(id: id)
    
    if conflicting_lessons.any?
      errors.add(:start_time, "conflicts with another lesson for this teacher")
    end
  end

  def available_for?(resource)
    Availability.where(
      available_for_type: resource.class.name,
      available_for_id: resource.id,
      available: true
    ).where(
      "start_time <= ? AND end_time > ?", start_time, start_time
    ).exists?
  end
end
