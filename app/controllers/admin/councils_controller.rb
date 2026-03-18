class Admin::CouncilsController < Admin::ApplicationController
  def index
    @councils = policy_scope(Council)
  end

  def new
    @council = Council.new
    authorize @council
  end

  def create
    @council = Council.new(council_params)
    authorize @council
    if @council.save
      redirect_to admin_councils_path, notice: "Council created successfully."
    else
      render :new
    end
  end

  private

  def council_params
    params.require(:council).permit(:name, :slug, :active)
  end
end
