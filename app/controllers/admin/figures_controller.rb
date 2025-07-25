class Admin::FiguresController < Admin::ApplicationController
  before_action :set_figure, only: [:show, :edit, :update, :destroy]

  def index
    @figures = Figure.order(:dance, :number)
  end

  def show
  end

  def new
    @figure = Figure.new
  end

  def edit
  end

  def create
    @figure = Figure.new(figure_params)
    
    if @figure.save
      redirect_to admin_figure_path(@figure), notice: 'Figure was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @figure.update(figure_params)
      redirect_to admin_figure_path(@figure), notice: 'Figure was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @figure.destroy
    redirect_to admin_figures_path, notice: 'Figure was successfully deleted.'
  end

  private

  def set_figure
    @figure = Figure.find(params[:id])
  end

  def figure_params
    params.require(:figure).permit(:name, :dance, :number, :bars, :components, :core, :level)
  end
end
