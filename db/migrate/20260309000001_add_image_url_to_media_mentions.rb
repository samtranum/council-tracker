class AddImageUrlToMediaMentions < ActiveRecord::Migration[6.1]
  def change
    add_column :media_mentions, :image_url, :text
  end
end
