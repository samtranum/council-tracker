class CreateUserCouncils < ActiveRecord::Migration[6.1]
  def change
    create_table :user_councils do |t|
      t.references :user, null: false, foreign_key: true
      t.references :council, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_councils, [:user_id, :council_id], unique: true
  end
end
