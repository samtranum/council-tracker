class CreateCouncils < ActiveRecord::Migration[6.1]
  def change
    create_table :councils do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :councils, :slug, unique: true
    add_index :councils, :name, unique: true
  end
end
