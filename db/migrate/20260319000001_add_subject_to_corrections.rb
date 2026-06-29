class AddSubjectToCorrections < ActiveRecord::Migration[6.1]
  def change
    add_column :corrections, :subject, :text
  end
end
