class AddSampleIndexToWells < ActiveRecord::Migration[5.2]
  def change
    remove_index :wells, :sample_id
    add_index :wells, :sample_id, unique: true
  end
end
