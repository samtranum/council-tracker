class LandingController < ApplicationController
  def index
    @councils = Council.where(active: true)
  end
end
