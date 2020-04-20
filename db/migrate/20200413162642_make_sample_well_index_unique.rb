class MakeSampleWellIndexUnique < ActiveRecord::Migration[5.2]
  def change
    remove_index :samples, :well_id
  end
end
