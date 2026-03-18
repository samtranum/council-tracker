class AddCouncilToCorrections < ActiveRecord::Migration[6.1]
  def change
    add_column :corrections, :council_id, :bigint
    add_index :corrections, :council_id
  end
end
