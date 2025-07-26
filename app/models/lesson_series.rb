class LessonSeries < ApplicationRecord
  belongs_to :teacher
  belongs_to :student
  belongs_to :location
  belongs_to :created_by, class_name: 'User'
  has_many :lessons, dependent: :nullify

  validates :title, presence: true
  validates :start_date, :end_date, presence: true
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :time_of_day, presence: true
  validates :duration, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[active paused cancelled completed] }

  validate :end_date_after_start_date
  validate :reasonable_duration

  scope :active, -> { where(status: 'active') }
  scope :for_teacher, ->(teacher) { where(teacher: teacher) }
  scope :for_student, ->(student) { where(student: student) }

  def day_name
    Date::DAYNAMES[day_of_week]
  end

  def generate_lessons!
    transaction do
      current_date = start_date
      instance_number = 1

      while current_date <= end_date
        # Find the next occurrence of the specified day of week
        days_until_target = (day_of_week - current_date.wday) % 7
        lesson_date = current_date + days_until_target.days

        break if lesson_date > end_date

        # Create lesson for this date
        lesson_start_time = lesson_date.beginning_of_day + 
                           time_of_day.hour.hours + 
                           time_of_day.min.minutes

        lessons.create!(
          student: student,
          teacher: teacher,
          location: location,
          start_time: lesson_start_time,
          duration: duration,
          series_instance_number: instance_number,
          status: 'scheduled',
          lesson_type: 'private',
          rate_charged: teacher.student_rate,
          teacher_pay: teacher.hourly_rate
        )

        current_date = lesson_date + 1.week
        instance_number += 1
      end
    end
  end

  def next_lesson_date
    return nil unless active?
    
    today = Date.current
    current_date = [start_date, today].max

    # Find next occurrence of the day
    days_until_target = (day_of_week - current_date.wday) % 7
    days_until_target = 7 if days_until_target == 0 && current_date > today
    
    next_date = current_date + days_until_target.days
    next_date <= end_date ? next_date : nil
  end

  def total_lessons_count
    return 0 unless start_date && end_date

    weeks_between = ((end_date - start_date) / 7).floor + 1
    
    # Calculate how many of the target day fall in the range
    first_occurrence = start_date + ((day_of_week - start_date.wday) % 7).days
    return 0 if first_occurrence > end_date
    
    ((end_date - first_occurrence) / 7).floor + 1
  end

  def completed_lessons_count
    lessons.where(status: ['completed', 'attended']).count
  end

  def progress_percentage
    return 0 if total_lessons_count == 0
    (completed_lessons_count.to_f / total_lessons_count * 100).round(1)
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def reasonable_duration
    return unless duration.present?
    
    if duration < 15 || duration > 240
      errors.add(:duration, "must be between 15 and 240 minutes")
    end
  end
end
