class RegenerateCouncillorSortNames < ActiveRecord::Migration[6.1]
  def up
    Councillor.find_each do |councillor|
      councillor.send(:set_given_and_family_names)
      councillor.send(:generate_sort_name)
      councillor.save!(validate: false)
    end
  end

  def down
    # irreversible
  end
end
