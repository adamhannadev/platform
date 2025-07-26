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
    params.require(:availability).permit(:start_time, :end_time)
  end
end
