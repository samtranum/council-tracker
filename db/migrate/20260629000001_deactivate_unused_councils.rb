class DeactivateUnusedCouncils < ActiveRecord::Migration[7.0]
  def up
    Council.where(name: ["Meath County Council", "Cork City Council", "Galway City Council"]).update_all(active: false)
  end

  def down
    Council.where(name: ["Meath County Council", "Cork City Council", "Galway City Council"]).update_all(active: true)
  end
end
