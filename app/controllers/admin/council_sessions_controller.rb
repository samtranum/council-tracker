class Admin::CouncilSessionsController < Admin::ApplicationController
  def index
    @council_sessions = policy_scope(CouncilSession).includes(:seats).order(commenced_on: :desc).page(params[:p])
  end

  def new
    @council_session = CouncilSession.new
    authorize @council_session
  end

  def create
    @council_session = CouncilSession.new(council_session_params)
    authorize @council_session
    if @council_session.save
      redirect_to admin_council_sessions_path, notice: "Council session created successfully."
    else
      render :new
    end
  end

  def edit
    @council_session = CouncilSession.find_by(commenced_on: params[:id])
    authorize @council_session
  end

  def update
    @council_session = CouncilSession.find_by(commenced_on: params[:id])
    authorize @council_session
    if @council_session.update(council_session_params)
      redirect_to admin_council_sessions_path, notice: "Council session updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @council_session = CouncilSession.find_by(commenced_on: params[:id])
    authorize @council_session
    @council_session.destroy
    redirect_to admin_council_sessions_path, notice: "Council session deleted successfully."
  end

  private

  def council_session_params
    params.require(:council_session).permit(:commenced_on, :concluded_on, :name)
  end
end
