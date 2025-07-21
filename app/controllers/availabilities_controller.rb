class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: %i[ show edit update destroy ]

  # GET /availabilities or /availabilities.json
  def index
  if params[:month]
    date = Date.parse(params[:month] + "-01")
  else
    date = Date.today
  end
  @first_day = date.beginning_of_month
  @last_day = date.end_of_month
  @days = (@first_day..@last_day).to_a
  @availabilities = Availability.where(available_on: @first_day..@last_day)

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

  def bulk_create_teacher
  teacher = Teacher.find(params[:teacher_id])
  start_date = (Date.today + 1.month).beginning_of_month
  end_date = start_date + 1.month

  (start_date..end_date).each do |date|
    weekday = date.wday # 0 = Sunday, 1 = Monday, ...
    if params["available_#{weekday}"] == "1"
      teacher.availabilities.create!(
        available_on: date,
        start_time: params["start_time_#{weekday}"],
        end_time: params["end_time_#{weekday}"],
        available: true
      )
    end
  end
  redirect_to teacher_path(teacher), notice: "Availabilities created for next month."
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def availability_params
      params.require(:availability).permit(:available_on, :start_time, :end_time, :available, :available_for_id, :available_for_type)
    end
end
