class AddHeaderFooterToCouncils < ActiveRecord::Migration[6.1]
  def change
    add_column :councils, :header_html, :text
    add_column :councils, :footer_html, :text
  end
end
