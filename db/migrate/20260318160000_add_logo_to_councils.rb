class AddLogoToCouncils < ActiveRecord::Migration[6.1]
  def change
    add_column :councils, :logo, :string
  end
end
