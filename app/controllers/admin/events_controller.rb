class Admin::EventsController < Admin::ApplicationController
  def index
    authorize Event
    @events = Event.by_occurred_on.page(params[:p])
  end

  def show
    @event = Event.find(params[:id])
    authorize @event
  end
end
