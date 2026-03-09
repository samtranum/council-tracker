class Admin::CouncillorsController < Admin::ApplicationController
  def index
    @councillors = Councillor.by_name.page(params[:p])
  end

  def show
    @councillor = Councillor.find_by(slug: params[:id])
  end

  def new
    @councillor = Councillor.new
  end

  def create
    @councillor = Councillor.new(councillor_params)
    if @councillor.save
      redirect_to admin_councillor_path(@councillor), notice: "Councillor created successfully."
    else
      render :new
    end
  end

  def edit
    @councillor = Councillor.find_by(slug: params[:id])
  end

  def update
    @councillor = Councillor.find_by(slug: params[:id])
    if @councillor.update(councillor_params)
      redirect_to admin_councillor_path(@councillor), notice: "Councillor updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @councillor = Councillor.find_by(slug: params[:id])
    @councillor.destroy
    redirect_to admin_councillors_path, notice: "Councillor deleted successfully."
  end

  private

  def councillor_params
    params.require(:councillor).permit(:full_name, :portrait, :council_id, :party_id, :local_electoral_area_id, :commenced_on)
  end
end
