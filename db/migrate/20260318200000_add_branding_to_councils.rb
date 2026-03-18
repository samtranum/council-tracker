class AddBrandingToCouncils < ActiveRecord::Migration[6.1]
  def change
    add_column :councils, :logo, :string
    add_column :councils, :footer_html, :text
  end
end
