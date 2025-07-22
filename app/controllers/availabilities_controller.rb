class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: %i[ show edit update destroy ]

  # GET /availabilities or /availabilities.json
  def index
    if params[:teacher_id]
      @teacher = Teacher.find(params[:teacher_id])
      @first_day = params[:month] ? Date.parse(params[:month] + "-01") : Date.today.beginning_of_month
      @last_day = @first_day.end_of_month
      @days = (@first_day..@last_day).to_a
      @availabilities = Availability.where(
        available_for_type: "Teacher",
        available_for_id: @teacher.id,
        start_time: @first_day.beginning_of_day..@last_day.end_of_day
      )
    elsif params[:location_id]
      @location = Location.find(params[:location_id])
      @first_day = params[:month] ? Date.parse(params[:month] + "-01") : Date.today.beginning_of_month
      @last_day = @first_day.end_of_month
      @days = (@first_day..@last_day).to_a
      @availabilities = Availability.where(
        available_for_type: "Location",
        available_for_id: @location.id,
        start_time: @first_day.beginning_of_day..@last_day.end_of_day
      )
    else
      @first_day = params[:month] ? Date.parse(params[:month] + "-01") : Date.today.beginning_of_month
      @last_day = @first_day.end_of_month
      @days = (@first_day..@last_day).to_a
      @availabilities = Availability.where(start_time: @first_day.beginning_of_day..@last_day.end_of_day)
    end
  end

  # GET /availabilities/1 or /availabilities/1.json
  def show
  end

  # GET /availabilities/new
  def new
    @availability = Availability.new
  end

  # GET /availabilities/1/edit
  def edit
  end

  # POST /availabilities or /availabilities.json
  def create
    @availability = Availability.new(availability_params)

    respond_to do |format|
      if @availability.save
        format.html { redirect_to availability_url(@availability), notice: "Availability was successfully created." }
        format.json { render :show, status: :created, location: @availability }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /availabilities/1 or /availabilities/1.json
  def update
    respond_to do |format|
      if @availability.update(availability_params)
        format.html { redirect_to availability_url(@availability), notice: "Availability was successfully updated." }
        format.json { render :show, status: :ok, location: @availability }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /availabilities/1 or /availabilities/1.json
  def destroy
    @availability.destroy!

    respond_to do |format|
      format.html { redirect_to availabilities_url, notice: "Availability was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def availability_params
      params.require(:availability).permit(:start_time, :end_time, :available, :available_for_id, :available_for_type)
    end
end
