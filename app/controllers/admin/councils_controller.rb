class Admin::CouncilsController < Admin::ApplicationController
  before_action :set_council, only: [:edit, :update]

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

  def edit
    authorize @council
  end

  def update
    authorize @council
    if @council.update(council_update_params)
      redirect_to admin_councils_path, notice: "Council updated successfully."
    else
      render :edit
    end
  end

  private

  def set_council
    @council = Council.find_by!(slug: params[:id])
  end

  def council_params
    params.require(:council).permit(:name, :slug, :active)
  end

  def council_update_params
    permitted = [:footer_html, :logo, :remove_logo]
    permitted += [:name, :slug, :active] if current_user.is_admin?
    params.require(:council).permit(*permitted)
  end
end
