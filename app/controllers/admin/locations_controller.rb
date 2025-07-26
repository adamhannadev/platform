class Admin::LocationsController < Admin::ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]

  def index
    @locations = Location.order(:name)
  end

  def show
    @lessons = Lesson.where(location: @location)
  end

  def new
    @location = Location.new
  end

  def edit
  end

  def create
    @location = Location.new(location_params)
    
    if @location.save
      redirect_to admin_location_path(@location), notice: 'Location was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @location.update(location_params)
      redirect_to admin_location_path(@location), notice: 'Location was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to admin_locations_path, notice: 'Location was successfully deleted.'
  end

  def schedules
    @location = Location.find(params[:id])
    @availabilities = @location.availabilities.order(:start_time)
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :rate)
  end
end
