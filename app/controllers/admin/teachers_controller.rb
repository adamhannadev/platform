class Admin::TeachersController < Admin::ApplicationController
  before_action :set_teacher, only: [:show, :edit, :update, :destroy]

  def index
    @teachers = Teacher.includes(:user).order(:first_name, :last_name)
  end

  def show
  end

  def new
    @teacher = Teacher.new
    @teacher.build_user
  end

  def edit
  end

  def create
    @teacher = Teacher.new(teacher_params)
    
    if @teacher.save
      redirect_to admin_teacher_path(@teacher), notice: 'Teacher was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @teacher.update(teacher_params)
      redirect_to admin_teacher_path(@teacher), notice: 'Teacher was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @teacher.destroy
    redirect_to admin_teachers_path, notice: 'Teacher was successfully deleted.'
  end

  def schedules
    @teacher = Teacher.find(params[:id])
    @availabilities = @teacher.availabilities.order(:start_time)
  end

  private

  def set_teacher
    @teacher = Teacher.find(params[:id])
  end

  def teacher_params
    params.require(:teacher).permit(:first_name, :last_name, :phone, :email, user_attributes: [:id, :email, :password, :password_confirmation, :role])
  end
end
