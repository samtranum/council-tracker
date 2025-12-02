require 'mini_magick'

class VoteImageGenerator
  WIDTH = 1200
  HEIGHT = 630
  PADDING = 60
  DOT_SIZE = 16
  DOT_SPACING = 20
  DOTS_PER_ROW = 35

  def initialize(voteable)
    @voteable = voteable
    @title = determine_title
    @votes_for = voteable.votes.where(status: 'for')
    @votes_against = voteable.votes.where(status: 'against')
    @votes_abstain = voteable.votes.where(status: 'abstain')
  end

  def generate
    # Create a simple red canvas to test if image generation works at all
    tempfile = Tempfile.new(['canvas', '.png'])
    MiniMagick::Tool::Convert.new do |convert|
      convert << "xc:red"
      convert.merge! ["-size", "#{WIDTH}x#{HEIGHT}"]
      convert << tempfile.path
    end
    
    image = MiniMagick::Image.open(tempfile.path)
    image.format 'png'
    image.to_blob
  end

  private

  def determine_title
    case @voteable
    when Motion
      @voteable.title || @voteable.body || 'Motion'
    when Amendment
      "Amendment to #{@voteable.motion.title}"
    else
      'Vote'
    end
  end

  def wrap_text(text, max_chars)
    words = text.split(' ')
    lines = []
    current_line = []

    words.each do |word|
      if (current_line + [word]).join(' ').length > max_chars
        lines << current_line.join(' ')
        current_line = [word]
      else
        current_line << word
      end
    end
    lines << current_line.join(' ')
    lines[0...3] # Limit to 3 lines max
  end

  def draw_text(image, text, x, y, max_width, size, color, weight = 'normal')
    # Escape text for ImageMagick
    safe_text = text.to_s
    
    # Use annotate directly to avoid type.xml dependency
    image.mogrify do |c|
      c.gravity("NorthWest")
      c.pointsize(size)
      c.fill(color)
      c.annotate("0", "+#{x}+#{y}", safe_text)
    end
  end

  def draw_votes(image, votes, start_x, start_y)
    votes_by_party = votes.includes(councillor: :party).group_by { |v| v.councillor.party }
    
    x = start_x
    y = start_y
    dot_count = 0

    votes_by_party.each do |party, party_votes|
      color = party&.colour_hex || '#999999'
      
      party_votes.each do |vote|
        draw_circle(image, x, y, DOT_SIZE / 2, color)
        
        x += DOT_SPACING
        dot_count += 1
        
        if dot_count % DOTS_PER_ROW == 0
          x = start_x
          y += DOT_SPACING
        end
      end
    end
  end

  def draw_circle(image, x, y, radius, color)
    image.combine_options do |c|
      c.fill color
      c.stroke color
      c.draw "circle #{x},#{y} #{x + radius},#{y}"
    end
  end

  def calculate_section_height(vote_count)
    rows = (vote_count.to_f / DOTS_PER_ROW).ceil
    rows * DOT_SPACING + 10
  end
end
