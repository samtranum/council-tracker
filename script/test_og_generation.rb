# script/test_og_generation.rb
require_relative '../config/environment'

puts "Finding a motion with votes..."
motion = Motion.joins(:votes).group('motions.id').having('count(votes.id) > 0').first

if motion
  puts "Found motion: #{motion.title}"
  puts "Votes: #{motion.votes.count}"
  
  begin
    puts "Generating image..."
    generator = VoteImageGenerator.new(motion)
    image_blob = generator.generate
    
    output_path = Rails.root.join('test_og_output.png')
    File.open(output_path, 'wb') do |f|
      f.write(image_blob)
    end
    puts "Image saved to #{output_path}"
    puts "Size: #{File.size(output_path)} bytes"
  rescue => e
    puts "Error generating image: #{e.message}"
    puts e.backtrace
  end
else
  puts "No motion with votes found. Creating a dummy one..."
  # Create dummy data if needed, but hopefully there's data.
  # For now just exit if no data, user can help or we can seed.
end
