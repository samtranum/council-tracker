class MotionsController < ApplicationController
  before_action :require_council

  def index
    @motions = current_council.motions.published.by_occurred_on.page(params[:p])

    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: @motions.limit(5)
      end
    end
  end

  def show
    @motion = current_council.motions.published.find_by!(hashed_id: params[:id])
    @view = params[:view].try(:to_sym) || :votes
    @context = params[:context].try(:to_sym) || :full

    # Set meta tags for social media sharing
    if @context == :full
      set_meta_tags_for_motion(@motion)
    end

    case @context
    when :full
      render action: :show
    when :partial
      render partial: "motions/#{@view}", locals: {motion: @motion}
    else
      raise "Unhandled render context"
    end
  end

  private

  def set_meta_tags_for_motion(motion)
    votes_for = motion.votes.where(status: 'for').count
    votes_against = motion.votes.where(status: 'against').count
    votes_abstain = motion.votes.where(status: 'abstain').count
    
    description = if motion.rollcall? && (votes_for + votes_against + votes_abstain) > 0
      result_text = motion.vote_result == 'pass' ? 'Passed' : 'Failed'
      "#{result_text}: #{votes_for} for, #{votes_against} against, #{votes_abstain} abstentions"
    elsif motion.vote_result.present?
      "Vote #{motion.vote_result}ed by #{motion.vote_method} vote"
    else
      motion.body.presence || motion.title
    end

    image_url = motion_og_image_url(current_council, motion, v: motion.updated_at.to_i)
    set_meta_tags(
      title: motion.title,
      description: description,
      og: {
        title: motion.title,
        description: description,
        type: 'article',
        url: motion_url(current_council, motion),
        image: {
          _: image_url,
          width: 1200,
          height: 630,
          type: 'image/png'
        }
      },
      twitter: {
        card: 'summary_large_image',
        title: motion.title,
        description: description,
        image: image_url
      }
    )
  end
end
