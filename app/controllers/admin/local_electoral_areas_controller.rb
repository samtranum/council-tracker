class Admin::LocalElectoralAreasController < Admin::ApplicationController
  before_action :set_local_electoral_area, only: [:edit, :update, :destroy]

  def index
    @local_electoral_areas = policy_scope(LocalElectoralArea).by_name
    @councils = policy_scope(Council).order(:name)
    authorize LocalElectoralArea
  end

  def new
    @local_electoral_area = LocalElectoralArea.new
    authorize @local_electoral_area
  end

  def create
    @local_electoral_area = LocalElectoralArea.new(local_electoral_area_params)
    authorize @local_electoral_area

    if @local_electoral_area.save
      redirect_to admin_local_electoral_areas_path, notice: "#{@local_electoral_area.name} created successfully."
    else
      render :new
    end
  end

  def edit
    authorize @local_electoral_area
  end

  def update
    authorize @local_electoral_area
    if @local_electoral_area.update(local_electoral_area_params)
      redirect_to admin_local_electoral_areas_path, notice: "#{@local_electoral_area.name} updated successfully."
    else
      render :edit
    end
  end

  def destroy
    authorize @local_electoral_area
    @local_electoral_area.destroy
    redirect_to admin_local_electoral_areas_path, notice: "Local Electoral Area deleted."
  end

  private

  def set_local_electoral_area
    @local_electoral_area = LocalElectoralArea.find_by!(slug: params[:id])
  end

  def local_electoral_area_params
    params.require(:local_electoral_area).permit(:name, :council_id, :slug)
  end
end
