class AddColorToParties < ActiveRecord::Migration[6.1]
  def up
    add_column :parties, :color, :string
    
    # Set default colors based on existing CSS
    Party.reset_column_information
    
    # Map existing parties to their colors from CSS
    color_map = {
      'sinn-fein' => '#008800',
      'fianna-fail' => '#66BB66',
      'fine-gael' => '#6699FF',
      'labour-party' => '#CC0000',
      'people-before-profit' => '#E91D50',
      'green-party' => '#99CC33',
      'solidarity' => '#BF2D2E',
      'united-left' => '#FF5555',
      'independent' => '#CCCCCC',
      'independents-4-change' => '#FFC0CB',
      'social-democrats' => '#752F8B',
      'workers-party' => '#D73D3D'
    }
    
    color_map.each do |slug, color|
      party = Party.find_by(slug: slug)
      party.update_column(:color, color) if party.present?
    end
    
    # Set a default gray for any parties without a color
    Party.where(color: nil).update_all(color: '#999999')
  end
  
  def down
    remove_column :parties, :color
  end
end
