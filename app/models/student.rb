class Student < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :charts
  has_many :figures, through: :charts
  has_many :booking_requests, dependent: :destroy
  has_many :lesson_series, dependent: :destroy
  belongs_to :user, optional: true

  accepts_nested_attributes_for :user

  validates :first_name, :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def name
    full_name
  end

  def lessons_for_period(start_date, end_date)
    lessons.for_date_range(start_date, end_date)
  end

  def total_lessons_taken_for_period(start_date, end_date)
    lessons_for_period(start_date, end_date)
      .where(status: ['completed', 'attended'])
      .count
  end

  def total_spent_for_period(start_date, end_date)
    lessons_for_period(start_date, end_date)
      .where(status: ['completed', 'attended'])
      .sum(:rate_charged)
  end

  def active_lesson_series
    lesson_series.where(status: 'active')
  end

  def upcoming_lessons(limit = 5)
    lessons.where(status: ['scheduled', 'confirmed'])
      .where('start_time > ?', Time.current)
      .order(:start_time)
      .limit(limit)
  end
end
