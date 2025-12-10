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
    # Create a white canvas using ImageMagick
    tempfile = Tempfile.new(['canvas', '.png'])
    tempfile.close # Close the file so that ImageMagick can write to it (Windows file locking)
    
    self.class.tool_class.new do |cmd|
      cmd << "xc:white"
      cmd.merge! ["-size", "#{WIDTH}x#{HEIGHT}"]
      cmd << tempfile.path
    end
    image = MiniMagick::Image.open(tempfile.path)

    # Draw title (with wrapping)
    current_y = 80
    title_lines = wrap_text(@title, 40) # Wrap at ~40 chars
    
    title_lines.each do |line|
      draw_text(image, line, 60, current_y, 900, 48, '#1a1a1a', 'bold')
      current_y += 60 # Line height
    end

    # Draw vote counts summary
    current_y += 30 # Spacing after title
    summary = "For: #{@votes_for.count}  •  Against: #{@votes_against.count}  •  Abstain: #{@votes_abstain.count}"
    draw_text(image, summary, 60, current_y, 900, 28, '#666666')

    # Draw result
    result_text = @voteable.vote_result == 'pass' ? 'PASSED' : 'FAILED'
    result_color = @voteable.vote_result == 'pass' ? '#22c55e' : '#ef4444'
    draw_text(image, result_text, 60, HEIGHT - 80, 900, 48, result_color, 'bold')

    # Draw vote visualization
    if @voteable.rollcall? && (@votes_for.count + @votes_against.count) > 0
      y_offset = current_y + 70 # Start visualization below summary
      
      # Draw "For" section
      if @votes_for.any?
        draw_text(image, 'For', 60, y_offset, 100, 20, '#666666')
        draw_votes(image, @votes_for, 60, y_offset + 30)
        y_offset += calculate_section_height(@votes_for.count) + 40
      end

      # Draw "Against" section
      if @votes_against.any?
        draw_text(image, 'Against', 60, y_offset, 100, 20, '#666666')
        draw_votes(image, @votes_against, 60, y_offset + 30)
      end
    end

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
    # Explicitly use the bundled font
    font_path = Rails.root.join('public', 'fonts', 'Roboto-Regular.ttf').to_s
    
    # Fallback to standard font if custom font not found
    font_arg = File.exist?(font_path) ? font_path : 'Helvetica'
    
    self.class.tool_class.new do |m|
      m << image.path
      m.font(font_arg)
      m.gravity("NorthWest")
      m.pointsize(size)
      m.fill(color)
      m.annotate("+#{x}+#{y}", safe_text)
      m << image.path
    end
  end

  def self.tool_class
    @tool_class ||= system_has_magick? ? MiniMagick::Tool::Magick : MiniMagick::Tool::Convert
  end

  def self.system_has_magick?
    # Check if 'magick' command exists (IM7)
    system('magick -version', out: File::NULL, err: File::NULL)
  rescue
    false
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
    # Use mogrify for drawing circles too, to be consistent
    self.class.tool_class.new do |m|
      m << image.path
      m.fill color
      m.stroke color
      m.draw "circle #{x},#{y} #{x + radius},#{y}"
      m << image.path
    end
  end

  def calculate_section_height(vote_count)
    rows = (vote_count.to_f / DOTS_PER_ROW).ceil
    rows * DOT_SPACING + 10
  end
end
