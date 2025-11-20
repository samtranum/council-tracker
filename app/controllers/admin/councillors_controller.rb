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
    params.require(:councillor).permit(:given_name, :family_name, :full_name, :gender, :born_on, :sort_name, :slug, :dcc_id, :portrait_file, :council_id)
  end
end
