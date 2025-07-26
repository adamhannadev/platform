class Admin::BookingRequestsController < Admin::ApplicationController
  before_action :set_booking_request, only: [:show, :approve, :reject]

  def index
    @pending_requests = BookingRequest.pending
                                     .includes(:student, :teacher, :location)
                                     .order(:requested_start_time)
    
    @recent_requests = BookingRequest.where(status: ['approved', 'rejected'])
                                    .includes(:student, :teacher, :location, :approved_by)
                                    .order(updated_at: :desc)
                                    .limit(20)
    
    @stats = {
      pending_count: BookingRequest.pending.count,
      approved_today: BookingRequest.approved.where(approved_at: Date.current.all_day).count,
      rejected_today: BookingRequest.rejected.where(approved_at: Date.current.all_day).count
    }
  end

  def show
    @lessons = @booking_request.lesson if @booking_request.approved?
  end

  def approve
    begin
      @booking_request.approve!(current_user)
      redirect_to admin_booking_requests_path, 
                  notice: "Booking request approved and lesson created successfully."
    rescue => e
      redirect_to admin_booking_request_path(@booking_request), 
                  alert: "Failed to approve booking: #{e.message}"
    end
  end

  def reject
    rejection_reason = params[:rejection_reason]
    
    if rejection_reason.present?
      @booking_request.reject!(rejection_reason, current_user)
      redirect_to admin_booking_requests_path, 
                  notice: "Booking request rejected."
    else
      redirect_to admin_booking_request_path(@booking_request), 
                  alert: "Please provide a rejection reason."
    end
  end

  private

  def set_booking_request
    @booking_request = BookingRequest.find(params[:id])
  end
end
