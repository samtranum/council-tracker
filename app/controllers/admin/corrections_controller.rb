class Admin::CorrectionsController < Admin::ApplicationController
  def index
    authorize Correction
    @corrections = Correction.order("created_at desc").page(params[:p])
  end

  def show
    @correction = Correction.find(params[:id])
    authorize @correction
  end
end
