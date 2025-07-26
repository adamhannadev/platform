class Admin::AvailabilitiesController < Admin::ApplicationController
  before_action :set_availability, only: [:show, :edit, :update, :destroy]
  before_action :set_polymorphic_parent, only: [:new, :create]
  before_action :set_parent_for_availability, only: [:edit, :update, :show]

  def index
    if @parent
      # When viewing availabilities for a specific teacher or location
      @availabilities = @parent.availabilities.order(:start_time)
    else
      # When viewing all availabilities
      @availabilities = Availability.includes(:available_for).order(:start_time)
      @teachers = Teacher.joins(:availabilities).distinct
      @locations = Location.joins(:availabilities).distinct
    end
  end

  def teacher_availability
    @teachers = Teacher.includes(:availabilities).order(:first_name, :last_name)
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @start_date = @current_date.beginning_of_month
    @end_date = @current_date.end_of_month
    
    # Get all teacher availabilities for the month
    @teacher_availabilities = Availability.where(
      available_for_type: 'Teacher',
      start_time: @start_date.beginning_of_day..@end_date.end_of_day
    ).includes(:available_for).group_by(&:available_for_id)
  end

  def location_availability
    @locations = Location.includes(:availabilities).order(:name)
    @current_date = params[:date] ? Date.parse(params[:date]) : Date.current
    @start_date = @current_date.beginning_of_month
    @end_date = @current_date.end_of_month
    
    # Get all location availabilities for the month
    @location_availabilities = Availability.where(
      available_for_type: 'Location',
      start_time: @start_date.beginning_of_day..@end_date.end_of_day
    ).includes(:available_for).group_by(&:available_for_id)
  end

  def new_teacher_availability
    @selected_teacher = Teacher.find(params[:teacher_id]) if params[:teacher_id].present?
    @teachers = Teacher.order(:first_name, :last_name)
    @availability = Availability.new
    
    # Set default values
    @availability.available_for_type = "Teacher"
    @availability.available_for_id = @selected_teacher&.id
    @availability.available = true
    
    # Set default date/time - tomorrow at 9 AM to 5 PM
    default_date = Date.current + 1.day
    @availability.start_time = default_date.beginning_of_day + 9.hours
    @availability.end_time = default_date.beginning_of_day + 17.hours
    
    # Override with URL params if provided
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        @availability.start_time = date.beginning_of_day + 9.hours
        @availability.end_time = date.beginning_of_day + 17.hours
      rescue Date::Error
        # Keep default values if parsing fails
      end
    end
  end

  def new_location_availability
    @selected_location = Location.find(params[:location_id]) if params[:location_id].present?
    @locations = Location.order(:name)
    @availability = Availability.new
    
    # Set default values
    @availability.available_for_type = "Location"
    @availability.available_for_id = @selected_location&.id
    @availability.available = true
    
    # Set default date/time - tomorrow at 8 AM to 10 PM
    default_date = Date.current + 1.day
    @availability.start_time = default_date.beginning_of_day + 8.hours
    @availability.end_time = default_date.beginning_of_day + 22.hours
    
    # Override with URL params if provided
    if params[:date].present?
      begin
        date = Date.parse(params[:date])
        @availability.start_time = date.beginning_of_day + 8.hours
        @availability.end_time = date.beginning_of_day + 22.hours
      rescue Date::Error
        # Keep default values if parsing fails
      end
    end
  end

  def create_teacher_availability
    @availability = Availability.new(availability_params)
    
    if @availability.save
      teacher = @availability.available_for
      redirect_to teacher_availability_admin_availabilities_path, 
                  notice: "Availability for #{teacher.name} was successfully created."
    else
      @teachers = Teacher.order(:first_name, :last_name)
      @selected_teacher = Teacher.find(@availability.available_for_id) if @availability.available_for_id.present?
      render :new_teacher_availability, status: :unprocessable_entity
    end
  end

  def create_location_availability
    @availability = Availability.new(availability_params)
    
    if @availability.save
      location = @availability.available_for
      redirect_to location_availability_admin_availabilities_path, 
                  notice: "Availability for #{location.name} was successfully created."
    else
      @locations = Location.order(:name)
      @selected_location = Location.find(@availability.available_for_id) if @availability.available_for_id.present?
      render :new_location_availability, status: :unprocessable_entity
    end
  end

  def show
  end

  def new
    @availability = @parent.availabilities.build
  end

  def edit
    @parent = @availability.available_for
  end

  def create
    @availability = @parent.availabilities.build(availability_params)
    
    if @availability.save
      redirect_to polymorphic_path([:admin, @parent, :availabilities]), notice: 'Availability was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @availability.update(availability_params)
      redirect_to admin_availability_path(@availability), notice: 'Availability was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    parent = @availability.available_for
    @availability.destroy
    redirect_to polymorphic_path([:admin, parent, :availabilities]), notice: 'Availability was successfully deleted.'
  end

  private

  def set_availability
    @availability = Availability.find(params[:id])
  end

  def set_polymorphic_parent
    if params[:teacher_id]
      @parent = Teacher.find(params[:teacher_id])
    elsif params[:location_id]
      @parent = Location.find(params[:location_id])
    elsif action_name == 'index'
      # Allow index without a parent to show all availabilities
      @parent = nil
    else
      redirect_to admin_root_path, alert: 'Invalid availability context.'
    end
  end

  def set_parent_for_availability
    @parent = @availability.available_for
  end

  def availability_params
    params.require(:availability).permit(:start_time, :end_time, :available, :available_for_type, :available_for_id)
  end
end
