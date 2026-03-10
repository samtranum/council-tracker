require 'mini_magick'

class VoteImageGenerator
  WIDTH = 1200
  HEIGHT = 630
  PADDING = 60
  DOT_RADIUS = 15
  DOT_SPACING = 38  # center-to-center
  DOTS_PER_ROW = ((WIDTH - PADDING * 2) / DOT_SPACING).floor  # ~28

  def initialize(voteable)
    @voteable = voteable
    @votes_for = voteable.votes.where(status: 'for')
    @votes_against = voteable.votes.where(status: 'against')
  end

  def generate
    tempfile = Tempfile.new(['canvas', '.png'])
    tempfile.close

    self.class.tool_class.new do |cmd|
      cmd.merge! ["-size", "#{WIDTH}x#{HEIGHT}"]
      cmd << "xc:white"
      cmd << tempfile.path
    end
    image = MiniMagick::Image.open(tempfile.path)

    # Calculate layout — two sections (FOR and AGAINST) vertically centred
    label_h    = 36
    label_gap  = 12
    section_gap = 60

    for_rows     = (@votes_for.count.to_f / DOTS_PER_ROW).ceil.clamp(1, 5)
    against_rows = (@votes_against.count.to_f / DOTS_PER_ROW).ceil.clamp(1, 5)

    for_section_h     = label_h + label_gap + (for_rows * DOT_SPACING)
    against_section_h = label_h + label_gap + (against_rows * DOT_SPACING)
    total_h = for_section_h + section_gap + against_section_h

    start_y = (HEIGHT - total_h) / 2

    # FOR section
    draw_text(image, 'FOR', PADDING, start_y, 200, 28, '#7b7cf7', 'bold')
    draw_votes(image, @votes_for, PADDING, start_y + label_h + label_gap)

    # AGAINST section
    against_y = start_y + for_section_h + section_gap
    draw_text(image, 'AGAINST', PADDING, against_y, 250, 28, '#f8a090', 'bold')
    draw_votes(image, @votes_against, PADDING, against_y + label_h + label_gap)

    image.format 'png'
    image.to_blob
  end

  private

  FONT_DIR      = Rails.root.join('lib', 'fonts')
  FONT_PATH     = "#{FONT_DIR}/DejaVuSans.ttf"
  FONT_PATH_BOLD = "#{FONT_DIR}/DejaVuSans-Bold.ttf"

  def draw_text(image, text, x, y, _max_width, size, color, weight = 'normal')
    font = weight == 'bold' ? FONT_PATH_BOLD : FONT_PATH
    self.class.tool_class.new do |m|
      m << image.path
      m.gravity('NorthWest')
      m.font(font)
      m.pointsize(size)
      m.fill(color)
      m.annotate("+#{x}+#{y}", text.to_s)
      m << image.path
    end
  end

  def draw_votes(image, votes, start_x, start_y)
    votes_by_party = votes.includes(:councillor).group_by { |v| v.councillor.party }

    x = start_x + DOT_RADIUS
    y = start_y + DOT_RADIUS
    dot_count = 0

    votes_by_party.each do |party, party_votes|
      raw   = party&.colour_hex || '999999'
      color = raw.start_with?('#') ? raw : "##{raw}"

      party_votes.each do
        draw_circle(image, x, y, DOT_RADIUS, color)
        x += DOT_SPACING
        dot_count += 1

        if dot_count % DOTS_PER_ROW == 0
          x  = start_x + DOT_RADIUS
          y += DOT_SPACING
        end
      end
    end
  end

  def draw_circle(image, x, y, radius, color)
    self.class.tool_class.new do |m|
      m << image.path
      m.fill(color)
      m.stroke(color)
      m.draw("circle #{x},#{y} #{x + radius},#{y}")
      m << image.path
    end
  end

  def self.tool_class
    @tool_class ||= system_has_magick? ? MiniMagick::Tool::Magick : MiniMagick::Tool::Convert
  end

  def self.system_has_magick?
    system('magick -version', out: File::NULL, err: File::NULL)
  rescue
    false
  end
end
