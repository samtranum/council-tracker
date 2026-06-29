class Admin::CorrectionsController < Admin::ApplicationController
  def index
    authorize Correction
    @corrections = policy_scope(Correction).order("created_at desc").page(params[:p])
  end

  def show
    @correction = Correction.find(params[:id])
    authorize @correction
  end

  def destroy
    @correction = Correction.find(params[:id])
    authorize @correction
    @correction.destroy
    redirect_to [:admin, :corrections], notice: "Correction deleted."
  end
end
