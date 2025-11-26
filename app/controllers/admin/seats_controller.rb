class Admin::SeatsController < Admin::ApplicationController
  before_action :set_councillor
  before_action :set_seat, only: [:edit, :update, :destroy]

  def index
    @seats = @councillor.seats.includes(:council_session, { party_affiliations: :party }, :local_electoral_area).order(commenced_on: :desc)
  end

  def new
    @seat = @councillor.seats.new
    @ended_seats = Seat.joins(:councillor)
                       .where.not(concluded_on: nil)
                       .select('seats.*, councillors.full_name as councillor_name')
                       .order('concluded_on DESC')
  end

  def create
    @seat = @councillor.seats.new(seat_params)
    if @seat.save
      redirect_to [:admin, @councillor, :terms], notice: 'Term was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @seat.update(seat_params)
      redirect_to [:admin, @councillor, :terms], notice: 'Term was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @seat.destroy
    redirect_to [:admin, @councillor, :terms], notice: 'Term was successfully deleted.'
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
end
