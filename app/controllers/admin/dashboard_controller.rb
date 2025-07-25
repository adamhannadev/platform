class Admin::DashboardController < Admin::ApplicationController
  def index
    @users_count = User.count
    @students_count = Student.count
    @teachers_count = Teacher.count
    @locations_count = Location.count
    @figures_count = Figure.count
    @availabilities_count = Availability.count
    @lessons_count = Lesson.count
  end
end
