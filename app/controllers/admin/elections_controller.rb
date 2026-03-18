class Admin::ElectionsController < Admin::ApplicationController
  def show
    @election = Election.find(params[:id])
    authorize @election
  end

  def new
    @election = Election.new(occurred_on: Date.current)
    authorize @election
  end

  def create
    @election = Election.create_from_date_and_csv!(election_params[:occurred_on], File.read(election_params[:election_csv].path))
    authorize @election
    if @election.save
      redirect_to [:admin, @election]
    else
      render :new
    end
  end

  private

  def election_params
    params.require(:election).permit(:occurred_on, :election_csv)
  end
end
