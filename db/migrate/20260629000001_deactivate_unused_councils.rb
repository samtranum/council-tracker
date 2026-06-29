class DeactivateUnusedCouncils < ActiveRecord::Migration[7.0]
  def up
    Council.where(name: ["Meath", "Cork", "Galway"]).update_all(active: false)
  end

  def down
    Council.where(name: ["Meath", "Cork", "Galway"]).update_all(active: true)
  end
end
