class Admin::CouncilSessionsController < Admin::ApplicationController
  def index
    @council_sessions = CouncilSession.includes(:council).order(commenced_on: :desc).page(params[:p])
  end

  def new
    @council_session = CouncilSession.new
  end

  def create
    @council_session = CouncilSession.new(council_session_params)
    if @council_session.save
      redirect_to admin_council_sessions_path, notice: "Council session created successfully."
    else
      render :new
    end
  end

  def edit
    @council_session = CouncilSession.find(params[:id])
  end

  def update
    @council_session = CouncilSession.find(params[:id])
    if @council_session.update(council_session_params)
      redirect_to admin_council_sessions_path, notice: "Council session updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @council_session = CouncilSession.find(params[:id])
    @council_session.destroy
    redirect_to admin_council_sessions_path, notice: "Council session deleted successfully."
  end

  private

  def council_session_params
    params.require(:council_session).permit(:council_id, :commenced_on, :concluded_on)
  end
end
