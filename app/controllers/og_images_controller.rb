class OgImagesController < ApplicationController
  before_action :set_cache_headers

  def motion
    council = Council.find_by!(slug: params[:council_id])
    @voteable = council.motions.published.find_by!(hashed_id: params[:id])
    
    generate_and_send_image
  end

  def amendment
    @voteable = Amendment.find_by!(hashed_id: params[:id])
    
    generate_and_send_image
  end

  private

  def generate_and_send_image
    image_blob = VoteImageGenerator.new(@voteable).generate
    
    send_data image_blob, 
      type: 'image/png', 
      disposition: 'inline',
      filename: "vote-#{@voteable.hashed_id}.png"
  rescue => e
    Rails.logger.error "OG Image Generation Failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    head :internal_server_error
  end

  def set_cache_headers
    # Cache for 1 week
    expires_in 1.week, public: true
  end
end
