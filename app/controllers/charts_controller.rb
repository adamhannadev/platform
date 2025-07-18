# filepath: /home/adam/projects/platform/app/controllers/charts_controller.rb
class ChartsController < ApplicationController
  protect_from_forgery with: :null_session

  def toggle
    chart = Chart.find(params[:id])
    field = params[:field]
    value = params[:value]
    if %w[movement timing partnering].include?(field)
      chart.update(field => value)
      head :ok
    else
      head :bad_request
    end
  end
end