class BookingRequest < ApplicationRecord
  belongs_to :student
  belongs_to :teacher
  belongs_to :location
  belongs_to :approved_by, class_name: 'User', optional: true
  belongs_to :rejected_by, class_name: 'User', optional: true
  has_one :lesson, dependent: :nullify

  validates :requested_start_time, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending approved rejected cancelled] }
  
  validate :not_too_far_in_advance
  validate :teacher_available_at_requested_time
  validate :location_available_at_requested_time

  scope :pending, -> { where(status: 'pending') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :for_date_range, ->(start_date, end_date) { 
    where(requested_start_time: start_date.beginning_of_day..end_date.end_of_day) 
  }

  # Virtual attributes for form handling
  def requested_date
    requested_start_time&.to_date
  end

  def requested_date=(date)
    if date.present? && requested_time.present?
      self.requested_start_time = DateTime.parse("#{date} #{requested_time.strftime('%H:%M')}")
    elsif date.present?
      # Keep existing time if available, otherwise default to 9 AM
      existing_time = requested_start_time&.strftime('%H:%M') || '09:00'
      self.requested_start_time = DateTime.parse("#{date} #{existing_time}")
    end
  end

  def requested_time
    requested_start_time&.in_time_zone
  end

  def requested_time=(time)
    if time.present? && requested_date.present?
      self.requested_start_time = DateTime.parse("#{requested_date} #{time}")
    elsif time.present?
      # Keep existing date if available, otherwise use today
      existing_date = requested_start_time&.to_date || Date.current
      self.requested_start_time = DateTime.parse("#{existing_date} #{time}")
    end
  end

  def approve!(user)
    transaction do
      update!(
        status: 'approved',
        approved_by: user,
        approved_at: Time.current
      )
      create_lesson_from_request
    end
  end

  def reject!(reason, user)
    update!(
      status: 'rejected',
      rejection_reason: reason,
      rejected_by: user,
      rejected_at: Time.current
    )
  end

  def cancel!
    update!(
      status: 'cancelled',
      cancelled_at: Time.current
    )
  end

  def can_be_cancelled?
    return false unless %w[pending approved].include?(status)
    requested_start_time > 12.hours.from_now
  end

  def requested_end_time
    requested_start_time + duration.minutes
  end

  def teacher_available_at_time?
    return false unless teacher.present? && requested_start_time.present?

    # Check for conflicting lessons
    conflicting_lessons = teacher.lessons.where(
      status: ['scheduled', 'confirmed'],
      start_time: requested_start_time..(requested_start_time + duration.minutes)
    ).where.not(id: lesson&.id)

    conflicting_lessons.empty?
  end

  def location_available_at_time?
    return false unless location.present? && requested_start_time.present?

    # Check for conflicting lessons at the location
    conflicting_lessons = location.lessons.where(
      status: ['scheduled', 'confirmed'],
      start_time: requested_start_time..(requested_start_time + duration.minutes)
    ).where.not(id: lesson&.id)

    conflicting_lessons.empty?
  end

  private

  def not_too_far_in_advance
    return unless requested_start_time.present?
    
    if requested_start_time > 2.months.from_now
      errors.add(:requested_start_time, "cannot be more than 2 months in advance")
    end
  end

  def teacher_available_at_requested_time
    return unless teacher.present? && requested_start_time.present?

    # Check for conflicting lessons
    conflicting_lessons = teacher.lessons.where(
      status: ['scheduled', 'confirmed'],
      start_time: (requested_start_time - 4.hours)..(requested_start_time + 4.hours)
    ).where.not(id: lesson&.id)

    if conflicting_lessons.any?
      errors.add(:requested_start_time, "conflicts with existing lesson")
    end
  end

  def location_available_at_requested_time
    return unless location.present? && requested_start_time.present?

    # Check location availability
    conflicting_lessons = location.lessons.where(
      status: ['scheduled', 'confirmed'],
      start_time: requested_start_time..(requested_start_time + duration.minutes)
    ).where.not(id: lesson&.id)

    if conflicting_lessons.any?
      errors.add(:requested_start_time, "location is not available at requested time")
    end
  end

  def create_lesson_from_request
    Lesson.create!(
      student: student,
      teacher: teacher,
      location: location,
      start_time: requested_start_time,
      duration: duration,
      booking_request: self,
      status: 'scheduled',
      rate_charged: teacher.student_rate,
      teacher_pay: teacher.hourly_rate
    )
  end
end
