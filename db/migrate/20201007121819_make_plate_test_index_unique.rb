class MakePlateTestIndexUnique < ActiveRecord::Migration[6.0]
  def change
    remove_index :tests, :plate_id
    add_index :tests, :plate_id, unique: true
  end
end
