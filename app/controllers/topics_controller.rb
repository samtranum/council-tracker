class TopicsController < ApplicationController
  before_action :require_council

  def index
    @topics = current_council.motions.published.pluck(:tags).flatten.uniq.sort
  end

  def show
    @tag = params[:id].tr("-", " ").capitalize
    @motions = current_council.motions.published.in_category(@tag).includes(:meeting).page(params[:p])
    @view = params[:view].try(:to_sym) || :motions
    @context = params[:context].try(:to_sym) || :full

    case @context
    when :full
      render action: :show
    when :partial
      render partial: "topics/#{@view}", locals: {motions: @motions}
    else
      raise "Unhandled render context"
    end
  end
end
