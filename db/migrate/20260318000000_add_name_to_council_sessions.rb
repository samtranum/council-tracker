class AddNameToCouncilSessions < ActiveRecord::Migration[6.0]
  def up
    add_column :council_sessions, :name, :text
    CouncilSession.update_all(name: "Dublin City Council")
  end

  def down
    remove_column :council_sessions, :name
  end
end
