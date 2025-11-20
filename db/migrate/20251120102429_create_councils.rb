class CreateCouncils < ActiveRecord::Migration[6.1]
  def up
    create_table :councils do |t|
      t.text :name
      t.text :slug
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :council_sessions, :council, foreign_key: true
    add_reference :councillors, :council, foreign_key: true
    add_reference :local_electoral_areas, :council, foreign_key: true

    # Create default council
    dcc = Council.create!(name: "Dublin City Council", slug: "dcc", active: true)

    # Migrate existing data
    CouncilSession.update_all(council_id: dcc.id)
    Councillor.update_all(council_id: dcc.id)
    LocalElectoralArea.update_all(council_id: dcc.id)

    # Add null constraints
    change_column_null :council_sessions, :council_id, false
    change_column_null :councillors, :council_id, false
    change_column_null :local_electoral_areas, :council_id, false
  end

  def down
    remove_reference :local_electoral_areas, :council
    remove_reference :councillors, :council
    remove_reference :council_sessions, :council
    drop_table :councils
  end
end
