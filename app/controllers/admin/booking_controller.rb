class Admin::BookingController < Admin::ApplicationController
  before_action :set_form_data, only: [:new, :create, :index]

  def index
    # Calendar view for booking overview
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @start_date = @current_date.beginning_of_month
    @end_date = @current_date.end_of_month
    
    # Get all lessons in the current month for calendar display
    @lessons = Lesson.includes(:student, :teacher, :location)
                    .where(start_time: @start_date.beginning_of_day..@end_date.end_of_day)
                    .order(:start_time)
    
    # Group lessons by date for easy calendar rendering
    @lessons_by_date = @lessons.group_by { |lesson| lesson.start_time.to_date }
    
    # Get availability stats for the month
    @availability_stats = calculate_availability_stats(@start_date, @end_date)
  end

  def new
    @lesson = Lesson.new
    
    # Pre-populate from URL params if available
    @lesson.teacher_id = params[:teacher_id] if params[:teacher_id].present?
    @lesson.student_id = params[:student_id] if params[:student_id].present?
    @lesson.location_id = params[:location_id] if params[:location_id].present?
    @lesson.start_time = params[:start_time] if params[:start_time].present?
    @lesson.duration = params[:duration] || 45
    
    @selected_date = params[:date] ? Date.parse(params[:date]) : Date.current
  end

  def calendar_view
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @teacher_id = params[:teacher_id]
    @location_id = params[:location_id]
    
    render json: {
      html: render_to_string(
        partial: 'calendar_month',
        locals: {
          date: @date,
          teacher_id: @teacher_id,
          location_id: @location_id
        }
      )
    }
  end

  def available_days
    @location = Location.find(params[:location_id]) if params[:location_id].present?
    @teacher = Teacher.find(params[:teacher_id]) if params[:teacher_id].present?
    
    # Safely parse the date with error handling
    begin
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    rescue Date::Error, ArgumentError
      @date = Date.current
    end
    
    # Get availability for the month
    start_date = @date.beginning_of_month
    end_date = @date.end_of_month
    
    location_availabilities = @location ? 
      @location.availabilities.where(
        available: true,
        start_time: start_date.beginning_of_day..end_date.end_of_day
      ) : []
    
    teacher_availabilities = @teacher ?
      @teacher.availabilities.where(
        available: true,
        start_time: start_date.beginning_of_day..end_date.end_of_day
      ) : []
    
    # Find overlapping availability days
    if @location && @teacher
      location_days = location_availabilities.map { |a| a.start_time.to_date }
      teacher_days = teacher_availabilities.map { |a| a.start_time.to_date }
      @available_days = (location_days & teacher_days).uniq
    elsif @location
      @available_days = location_availabilities.map { |a| a.start_time.to_date }.uniq
    elsif @teacher
      @available_days = teacher_availabilities.map { |a| a.start_time.to_date }.uniq
    else
      @available_days = []
    end
    
    render json: {
      available_days: @available_days.map(&:to_s),
      html: render_to_string(
        partial: 'available_days_calendar',
        locals: {
          date: @date,
          available_days: @available_days,
          teacher: @teacher,
          location: @location
        }
      )
    }
  end

  def available_teachers
    @location = Location.find(params[:location_id])
    
    # Safely parse the date with error handling
    begin
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    rescue Date::Error, ArgumentError
      @date = Date.current
    end
    
    # Find teachers available on this date and location
    location_availability_times = @location.availabilities.where(
      available: true,
      start_time: @date.beginning_of_day..@date.end_of_day
    )
    
    teacher_ids = []
    location_availability_times.each do |loc_avail|
      # Find teachers available during the same time periods
      overlapping_teacher_ids = Availability.where(
        available_for_type: "Teacher",
        available: true
      ).where(
        "(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?)",
        loc_avail.start_time, loc_avail.start_time,
        loc_avail.end_time, loc_avail.end_time
      ).pluck(:available_for_id)
      
      teacher_ids.concat(overlapping_teacher_ids)
    end
    
    @teachers = Teacher.where(id: teacher_ids.uniq).order(:first_name, :last_name)
    
    render json: {
      html: render_to_string(
        partial: 'teacher_select',
        locals: { location: @location, date: @date, teachers: @teachers }
      )
    }
  end

  def available_timeslots
    @location = Location.find(params[:location_id])
    @teacher = Teacher.find(params[:teacher_id])
    
    # Safely parse the date with error handling
    begin
      @date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    rescue Date::Error, ArgumentError
      @date = Date.current
    end
    
    @duration = (params[:duration] || 45).to_i
    
    # Find overlapping availability between teacher and location
    teacher_availabilities = @teacher.availabilities.where(
      available: true,
      start_time: @date.beginning_of_day..@date.end_of_day
    )
    
    location_availabilities = @location.availabilities.where(
      available: true,
      start_time: @date.beginning_of_day..@date.end_of_day
    )
    
    timeslots = []
    
    teacher_availabilities.each do |teacher_avail|
      location_availabilities.each do |location_avail|
        # Find overlap between teacher and location availability
        overlap_start = [teacher_avail.start_time, location_avail.start_time].max
        overlap_end = [teacher_avail.end_time, location_avail.end_time].min
        
        next if overlap_start >= overlap_end
        
        # Generate time slots within the overlap
        slot_time = overlap_start
        while slot_time + @duration.minutes <= overlap_end
          timeslots << slot_time
          slot_time += 15.minutes # 15-minute intervals
        end
      end
    end
    
    # Remove already booked slots
    booked_times = Lesson.where(
      teacher: @teacher,
      location: @location,
      start_time: @date.beginning_of_day..@date.end_of_day
    ).pluck(:start_time)
    
    # Filter out slots that would conflict with existing lessons
    @available_timeslots = timeslots.uniq.reject do |slot|
      booked_times.any? do |booked|
        # Check if the new slot would overlap with existing lesson
        slot_end = slot + @duration.minutes
        booked_end = booked + 45.minutes # Assuming existing lessons are 45 min
        
        (slot >= booked && slot < booked_end) ||
        (slot_end > booked && slot_end <= booked_end) ||
        (slot <= booked && slot_end >= booked_end)
      end
    end.sort
    
    render json: {
      html: render_to_string(
        partial: 'timeslot_select',
        locals: {
          location: @location,
          teacher: @teacher,
          date: @date,
          timeslots: @available_timeslots,
          duration: @duration
        }
      )
    }
  end

  def create
    @lesson = Lesson.new(lesson_params)
    
    # Validate that start_time is present and valid
    if params[:lesson][:start_time].blank?
      @lesson.errors.add(:start_time, "must be selected")
    end
    
    if @lesson.errors.empty? && @lesson.save
      redirect_to admin_lesson_path(@lesson), 
                  notice: "Lesson successfully booked for #{@lesson.student.full_name}!"
    else
      set_form_data
      @selected_date = @lesson.start_time&.to_date || Date.current
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_form_data
    @teachers = Teacher.includes(:user).order(:first_name, :last_name)
    @students = Student.includes(:user).order(:first_name, :last_name)
    @locations = Location.order(:name)
    
    @duration_options = [
      [15, 15], [30, 30], [45, 45], [60, 60], 
      [75, 75], [90, 90], [120, 120]
    ]
  end

  def lesson_params
    params.require(:lesson).permit(:start_time, :student_id, :teacher_id, :location_id, :duration, :plan)
  end

  def calculate_availability_stats(start_date, end_date)
    total_teacher_hours = Availability.where(
      available_for_type: "Teacher",
      available: true,
      start_time: start_date.beginning_of_day..end_date.end_of_day
    ).sum { |a| (a.end_time - a.start_time) / 1.hour }
    
    total_location_hours = Availability.where(
      available_for_type: "Location",
      available: true,
      start_time: start_date.beginning_of_day..end_date.end_of_day
    ).sum { |a| (a.end_time - a.start_time) / 1.hour }
    
    booked_hours = Lesson.where(
      start_time: start_date.beginning_of_day..end_date.end_of_day
    ).sum { |l| l.duration / 60.0 }
    
    {
      total_teacher_hours: total_teacher_hours.round(1),
      total_location_hours: total_location_hours.round(1),
      booked_hours: booked_hours.round(1),
      utilization_rate: total_teacher_hours > 0 ? ((booked_hours / total_teacher_hours) * 100).round(1) : 0
    }
  end
end
