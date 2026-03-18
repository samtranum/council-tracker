class HomeController < ApplicationController
  before_action :require_council

  def show
    @council_session = current_council.council_sessions.current_on(Date.current).take
    @local_electoral_areas = @council_session.local_electoral_areas.by_name
    @parties = @council_session.parties.by_name
    @topics = Motion.published.pluck(:tags).flatten.uniq.sort
    @recent_motions = current_council.motions.published.order(occurred_on: :desc).limit(10)
  end
end
