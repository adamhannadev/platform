class BookingController < ApplicationController
  def new
    @locations = Location.all
  end

  def index

  end

  def available_days
    @location = Location.find(params[:location_id])
    availabilities = @location.availabilities.where(available: true)
    @days = availabilities.map { |a| a.start_time.to_date }.uniq

    if @days.empty?
      render turbo_stream: turbo_stream.append(
        "messages",
        partial: "shared/message",
        locals: { message: "No available days for this location." }
      )
    else
      render partial: "calendar", locals: { location: @location, days: @days }
    end
  end

  def available_teachers
    @location = Location.find(params[:location_id])
    @date = Date.parse(params[:date])
    teacher_ids = Availability.where(
      available_for_type: "Teacher",
      available: true,
      start_time: @date.beginning_of_day..@date.end_of_day
    ).pluck(:available_for_id)
    @teachers = Teacher.where(id: teacher_ids)
    render partial: "teacher_select", locals: { location: @location, date: @date, teachers: @teachers }
  end

  def available_timeslots
    @location = Location.find(params[:location_id])
    @teacher = Teacher.find(params[:teacher_id])
    @date = Date.parse(params[:date])
    availabilities = Availability.where(
      available_for_type: "Teacher",
      available_for_id: @teacher.id,
      available: true,
      start_time: @date.beginning_of_day..@date.end_of_day
    )
    timeslots = []
    availabilities.each do |a|
      block_time = a.start_time
      while block_time + 45.minutes <= a.end_time
        timeslots << block_time
        block_time += 45.minutes
      end
    end
    booked = Lesson.where(
      teacher: @teacher,
      location: @location,
      start_time: @date.beginning_of_day..@date.end_of_day
    ).pluck(:start_time)
    @timeslots = timeslots - booked
    render partial: "timeslot_select", locals: { location: @location, teacher: @teacher, date: @date, timeslots: @timeslots }
  end

  def create
    lesson = Lesson.new(
      student_id: current_user.student.id,
      teacher_id: params[:teacher_id],
      location_id: params[:location_id],
      start_time: params[:start_time],
      duration: 45
    )
    if lesson.save
      render partial: "booking_success"
    else
      render turbo_stream: turbo_stream.append(
        "messages",
        partial: "shared/message",
        locals: { message: lesson.errors.full_messages.to_sentence }
      ), status: :unprocessable_entity
    end
  end
end
