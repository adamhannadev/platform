class Admin::LessonsController < Admin::ApplicationController
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]
  before_action :set_form_data, only: [:new, :edit, :create, :update]

  def index
    @lessons = Lesson.includes(:student, :teacher, :location)
                    .order(start_time: :desc)
    
    # Add filtering capabilities
    if params[:teacher_id].present?
      @lessons = @lessons.where(teacher_id: params[:teacher_id])
    end
    
    if params[:student_id].present?
      @lessons = @lessons.where(student_id: params[:student_id])
    end
    
    if params[:location_id].present?
      @lessons = @lessons.where(location_id: params[:location_id])
    end
    
    if params[:date_from].present?
      @lessons = @lessons.where('start_time >= ?', Date.parse(params[:date_from]).beginning_of_day)
    end
    
    if params[:date_to].present?
      @lessons = @lessons.where('start_time <= ?', Date.parse(params[:date_to]).end_of_day)
    end
    
    # For filter dropdowns
    @teachers = Teacher.order(:first_name, :last_name)
    @students = Student.order(:first_name, :last_name)
    @locations = Location.order(:name)
  end

  def show
    @related_lessons = Lesson.where(student: @lesson.student)
                            .where.not(id: @lesson.id)
                            .includes(:teacher, :location)
                            .order(start_time: :desc)
                            .limit(5)
  end

  def new
    @lesson = Lesson.new
    
    # Pre-populate from URL params if available
    @lesson.teacher_id = params[:teacher_id] if params[:teacher_id].present?
    @lesson.student_id = params[:student_id] if params[:student_id].present?
    @lesson.location_id = params[:location_id] if params[:location_id].present?
    @lesson.start_time = params[:start_time] if params[:start_time].present?
    @lesson.duration = 45 # Default duration
  end

  def edit
  end

  def create
    @lesson = Lesson.new(lesson_params)
    
    if @lesson.save
      redirect_to admin_lesson_path(@lesson), notice: 'Lesson was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @lesson.update(lesson_params)
      redirect_to admin_lesson_path(@lesson), notice: 'Lesson was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    student_name = @lesson.student.full_name
    @lesson.destroy
    redirect_to admin_lessons_path, notice: "Lesson for #{student_name} was successfully deleted."
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def set_form_data
    @teachers = Teacher.includes(:user).order(:first_name, :last_name)
    @students = Student.includes(:user).order(:first_name, :last_name)
    @locations = Location.order(:name)
    
    # Duration options in minutes
    @duration_options = [
      [15, 15], [30, 30], [45, 45], [60, 60], 
      [75, 75], [90, 90], [120, 120]
    ]
  end

  def lesson_params
    params.require(:lesson).permit(:start_time, :student_id, :teacher_id, :location_id, :duration, :plan)
  end
end
