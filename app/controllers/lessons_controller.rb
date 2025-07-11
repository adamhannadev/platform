class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[show update destroy]

  def index
    render json: Lesson.all
  end

  def show
    render json: @lesson
  end

  def create
    lesson = Lesson.new(lesson_params)
    if lesson.save
      render json: lesson, status: :created
    else
      render json: lesson.errors, status: :unprocessable_entity
    end
  end

  def update
    if @lesson.update(lesson_params)
      render json: @lesson
    else
      render json: @lesson.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @lesson.destroy
    head :no_content
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:lesson_time, :student_id, :teacher_id, :plan)
  end
end