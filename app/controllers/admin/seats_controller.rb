class Admin::SeatsController < Admin::ApplicationController
  before_action :set_councillor
  before_action :set_seat, only: [:edit, :update, :destroy]

  def index
    authorize @councillor, :show?
    @seats = @councillor.seats.includes(:council_session, {party_affiliations: :party}, :local_electoral_area).order(commenced_on: :desc)
  end

  def new
    @seat = @councillor.seats.new
    authorize @seat
    load_ended_seats
  end

  def create
    @seat = @councillor.seats.new(seat_params)
    authorize @seat
    if @seat.save
      redirect_to [:admin, @councillor, :terms], notice: "Term was successfully created."
    else
      load_ended_seats
      render :new
    end
  end

  def edit
    authorize @seat
    load_ended_seats
  end

  def update
    authorize @seat
    if @seat.update(seat_params)
      redirect_to [:admin, @councillor, :terms], notice: "Term was successfully updated."
    else
      load_ended_seats
      render :edit
    end
  end

  def destroy
    authorize @seat
    @seat.destroy
    redirect_to [:admin, @councillor, :terms], notice: "Term was successfully deleted."
  end

  private

  def set_councillor
    @councillor = Councillor.find_by!(slug: params[:councillor_id])
  end

  def set_seat
    @seat = @councillor.seats.find(params[:id])
  end

  def seat_params
    params.require(:seat).permit(:council_session_id, :party_id, :local_electoral_area_id, :commenced_on, :concluded_on, :term_type, :replaced_seat_id)
  end

  def load_ended_seats
    @ended_seats = Seat.joins(:councillor)
                       .where.not(concluded_on: nil)
                       .where("seats.council_session_id = ?", (@seat.council_session_id || CouncilSession.current_on(Date.current).where(council_id: @councillor.council_id).first&.id))
                       .select("seats.id, seats.councillor_id, councillors.full_name as councillor_name, seats.concluded_on")
                       .order("concluded_on DESC")
                       .map { |s| ["#{s.councillor_name} (resigned #{s.concluded_on.strftime("%d %b %Y")})", s.id] }
  end
end
