class AmendmentsController < ApplicationController
  def show
    @amendment = Amendment.find_by(hashed_id: params[:id])
    @view = params[:view].try(:to_sym) || :votes
    @context = params[:context].try(:to_sym) || :full

    # Set meta tags for social media sharing
    if @context == :full
      set_meta_tags_for_amendment(@amendment)
    end

    case @context
    when :full
      render action: :show
    when :partial
      render partial: "amendments/#{@view}", locals: {amendment: @amendment}
    else
      raise "Unhandled render context"
    end
  end

  private

  def set_meta_tags_for_amendment(amendment)
    votes_for = amendment.votes.where(status: 'for').count
    votes_against = amendment.votes.where(status: 'against').count
    votes_abstain = amendment.votes.where(status: 'abstain').count
    
    title = "Amendment to #{amendment.motion.title}"
    
    description = if amendment.rollcall? && (votes_for + votes_against + votes_abstain) > 0
      result_text = amendment.vote_result == 'pass' ? 'Passed' : 'Failed'
      "#{result_text}: #{votes_for} for, #{votes_against} against, #{votes_abstain} abstentions"
    elsif amendment.vote_result.present?
      "Vote #{amendment.vote_result}ed by #{amendment.vote_method} vote"
    else
      amendment.body.presence || title
    end

    council = amendment.motion.meeting.council_session.council
    
    set_meta_tags(
      title: title,
      description: description,
      og: {
        title: title,
        description: description,
        type: 'article',
        url: amendment_url(council, amendment),
        image: amendment_og_image_url(council, amendment, v: amendment.updated_at.to_i)
      },
      twitter: {
        card: 'summary_large_image',
        title: title,
        description: description,
        image: amendment_og_image_url(council, amendment, v: amendment.updated_at.to_i)
      }
    )
  end
end
