class AddImageUrlToMediaMentions < ActiveRecord::Migration[7.0]
  def change
    add_column :media_mentions, :image_url, :text
  end
end
