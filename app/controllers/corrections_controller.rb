class CorrectionsController < ApplicationController
  def new
    @correction = Correction.new
  end

  def create
    @correction = Correction.new(correction_params)
    @correction.council = current_council
    if @correction.save
      CorrectionMailer.notify_editors(@correction).deliver_later
      redirect_to [:thanks, :corrections]
    else
      render :new
    end
  end

  def thanks
  end

  private

  def correction_params
    params.require(:correction).permit(
      :name,
      :email_address,
      :subject,
      :body
    )
  end
end
