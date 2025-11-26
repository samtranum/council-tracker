class AddTermTypeAndReplacementToSeats < ActiveRecord::Migration[6.1]
  def change
    add_column :seats, :term_type, :string
    add_column :seats, :replaced_seat_id, :integer
    add_index :seats, :replaced_seat_id
  end
end
