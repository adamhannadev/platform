class Admin::StudentsController < Admin::ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy, :charts]

  def index
    @students = Student.includes(:user).order(:first_name, :last_name)
  end

  def show
  end

  def new
    @student = Student.new
    @student.build_user
  end

  def edit
  end

  def create
    @student = Student.new(student_params)
    
    if @student.save
      redirect_to admin_student_path(@student), notice: 'Student was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # Handle nested user attributes password updates
    if params[:student][:user_attributes] && params[:student][:user_attributes][:password].blank?
      params[:student][:user_attributes].delete(:password)
      params[:student][:user_attributes].delete(:password_confirmation)
    end
    
    if @student.update(student_params)
      redirect_to admin_student_path(@student), notice: 'Student was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @student.destroy
    redirect_to admin_students_path, notice: 'Student was successfully deleted.'
  end

  def charts
    @charts = @student.charts.includes(:figure)
  end

  private

  def set_student
    @student = Student.find(params[:id])
  end

  def student_params
    params.require(:student).permit(:first_name, :last_name, :phone, :email, user_attributes: [:id, :email, :password, :password_confirmation, :role])
  end
end
