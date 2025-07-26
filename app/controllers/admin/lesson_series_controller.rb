class Admin::LessonSeriesController < Admin::ApplicationController
  before_action :set_lesson_series, only: [:show, :edit, :update, :destroy, :generate_lessons, :pause, :resume]

  def index
    @active_series = LessonSeries.active
                                 .includes(:teacher, :student, :location, :lessons)
                                 .order(:start_date)
    
    @paused_series = LessonSeries.where(status: 'paused')
                                 .includes(:teacher, :student, :location)
                                 .order(:updated_at)
    
    @completed_series = LessonSeries.where(status: ['completed', 'cancelled'])
                                   .includes(:teacher, :student, :location)
                                   .order(updated_at: :desc)
                                   .limit(10)
  end

  def show
    @lessons = @lesson_series.lessons
                            .includes(:student, :teacher, :location)
                            .order(:start_time)
    
    @upcoming_lessons = @lessons.where('start_time > ?', Time.current)
                               .where(status: ['scheduled', 'confirmed'])
                               .limit(5)
    
    @recent_lessons = @lessons.where(status: ['completed', 'attended', 'cancelled'])
                             .order(start_time: :desc)
                             .limit(10)
  end

  def new
    @lesson_series = LessonSeries.new
    @teachers = Teacher.order(:first_name, :last_name)
    @students = Student.order(:first_name, :last_name)
    @locations = Location.order(:name)
    
    # Set default end date to end of current year
    @lesson_series.end_date = Date.current.end_of_year
  end

  def create
    @lesson_series = LessonSeries.new(lesson_series_params)
    @lesson_series.created_by = current_user
    
    if @lesson_series.save
      @lesson_series.generate_lessons!
      redirect_to admin_lesson_series_path(@lesson_series), 
                  notice: "Lesson series created successfully with #{@lesson_series.total_lessons} lessons generated."
    else
      @teachers = Teacher.order(:first_name, :last_name)
      @students = Student.order(:first_name, :last_name)
      @locations = Location.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @teachers = Teacher.order(:first_name, :last_name)
    @students = Student.order(:first_name, :last_name)
    @locations = Location.order(:name)
  end

  def update
    if @lesson_series.update(lesson_series_params)
      redirect_to admin_lesson_series_path(@lesson_series), 
                  notice: "Lesson series updated successfully."
    else
      @teachers = Teacher.order(:first_name, :last_name)
      @students = Student.order(:first_name, :last_name)
      @locations = Location.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson_series.destroy
    redirect_to admin_lesson_series_index_path, 
                notice: "Lesson series deleted successfully."
  end

  def generate_lessons
    lessons_before = @lesson_series.total_lessons
    @lesson_series.generate_lessons!
    lessons_after = @lesson_series.total_lessons
    new_lessons = lessons_after - lessons_before
    
    redirect_to admin_lesson_series_path(@lesson_series), 
                notice: "Generated #{new_lessons} new lessons."
  end

  def pause
    @lesson_series.pause!
    redirect_to admin_lesson_series_path(@lesson_series), 
                notice: "Lesson series paused. Future lessons have been cancelled."
  end

  def resume
    @lesson_series.resume!
    redirect_to admin_lesson_series_path(@lesson_series), 
                notice: "Lesson series resumed and future lessons regenerated."
  end

  private

  def set_lesson_series
    @lesson_series = LessonSeries.find(params[:id])
  end

  def lesson_series_params
    params.require(:lesson_series).permit(:title, :teacher_id, :student_id, :location_id, 
                                         :start_date, :end_date, :day_of_week, :time_of_day, 
                                         :duration, :notes)
  end
end
