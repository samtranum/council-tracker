class Admin::PartiesController < Admin::ApplicationController
  before_action :set_party, only: [:edit, :update]

  def index
    authorize Party
    @parties = policy_scope(Party).by_name
  end

  def new
    @party = Party.new
    authorize @party
  end

  def create
    @party = Party.new(party_params)
    authorize @party
    if @party.save
      redirect_to admin_parties_path, notice: "Party #{@party.name} created successfully."
    else
      render :new
    end
  end

  def edit
    authorize @party
  end

  def update
    authorize @party
    if @party.update(party_params)
      redirect_to admin_parties_path, notice: "Party #{@party.name} updated successfully."
    else
      render :edit
    end
  end

  private

  def set_party
    @party = Party.find_by!(slug: params[:id])
  end

  def party_params
    params.require(:party).permit(:name, :color)
  end
end
