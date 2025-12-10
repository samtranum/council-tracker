class Admin::PartiesController < Admin::ApplicationController
  before_action :set_party, only: [:edit, :update]

  def index
    @parties = Party.by_name
  end

  def edit
  end

  def update
    if @party.update(party_params)
      redirect_to admin_parties_path, notice: "Party #{@party.name} updated successfully."
    else
      render :edit
    end
  end

  private

  def set_party
    @party = Party.find(params[:id])
  end

  def party_params
    params.require(:party).permit(:name, :color)
  end
end
