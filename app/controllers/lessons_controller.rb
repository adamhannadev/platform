class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /lessons or /lessons.json
  def index
    @lessons = Lesson.all
  end

  # GET /lessons/1 or /lessons/1.json
  def show
  end

  # GET /lessons/1/edit
  def edit
  end

  # PATCH/PUT /lessons/1 or /lessons/1.json
  def update
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to lesson_url(@lesson), notice: "Lesson was successfully updated." }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1 or /lessons/1.json
  def destroy
    @lesson.destroy!

    respond_to do |format|
      format.html { redirect_to lessons_url, notice: "Lesson was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def new
    @locations = Location.all
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
      render partial: "booking_success" # create _booking_success.html.erb with a success message
    else
      render partial: "timeslot_select", locals: { location: Location.find(params[:location_id]), teacher: Teacher.find(params[:teacher_id]), date: params[:date], timeslots: [] }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lesson
      @lesson = Lesson.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lesson_params
      params.require(:lesson).permit(:start_time, :student_id, :teacher_id, :plan, :location_id, :duration)
    end
end
