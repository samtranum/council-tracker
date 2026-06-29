class AddBrandingToCouncils < ActiveRecord::Migration[6.1]
  def change
    add_column :councils, :logo, :string unless column_exists?(:councils, :logo)
    add_column :councils, :footer_html, :text unless column_exists?(:councils, :footer_html)
  end
end
