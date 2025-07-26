class BookingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student_role
  before_action :set_booking_request, only: [:show, :cancel]

  def index
    @current_student = current_user.students.first
    return redirect_to root_path, alert: "No student profile found" unless @current_student
    
    @pending_requests = @current_student.booking_requests
                                       .pending
                                       .includes(:teacher, :location)
                                       .order(:requested_start_time)
    
    @recent_requests = @current_student.booking_requests
                                      .where(status: ['approved', 'rejected'])
                                      .includes(:teacher, :location, :lesson)
                                      .order(updated_at: :desc)
                                      .limit(10)
  end

  def show
    @lesson = @booking_request.lesson if @booking_request.approved?
  end

  def new
    @current_student = current_user.students.first
    return redirect_to root_path, alert: "No student profile found" unless @current_student
    
    @booking_request = BookingRequest.new
    @teachers = Teacher.order(:first_name, :last_name)
    @locations = Location.order(:name)
    
    # Set default duration
    @booking_request.duration = 45
  end

  def create
    @current_student = current_user.students.first
    return redirect_to root_path, alert: "No student profile found" unless @current_student
    
    @booking_request = @current_student.booking_requests.build(booking_request_params)
    
    if @booking_request.save
      redirect_to booking_requests_path, 
                  notice: "Booking request submitted successfully! You'll receive confirmation once it's approved."
    else
      @teachers = Teacher.order(:first_name, :last_name)
      @locations = Location.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    if @booking_request.can_be_cancelled?
      @booking_request.update!(status: 'cancelled')
      redirect_to booking_requests_path, notice: "Booking request cancelled."
    else
      redirect_to booking_request_path(@booking_request), 
                  alert: "This booking request cannot be cancelled."
    end
  end

  private

  def set_booking_request
    @current_student = current_user.students.first
    @booking_request = @current_student.booking_requests.find(params[:id])
  end

  def ensure_student_role
    unless current_user&.role == 'student' || current_user&.students&.any?
      redirect_to root_path, alert: "Access denied."
    end
  end

  def booking_request_params
    params.require(:booking_request).permit(:teacher_id, :location_id, :requested_start_time, :duration, :notes)
  end
end
