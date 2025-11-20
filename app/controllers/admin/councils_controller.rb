class Admin::CouncilsController < Admin::ApplicationController
  def index
    @councils = Council.all
  end

  def new
    @council = Council.new
  end

  def create
    @council = Council.new(council_params)
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
