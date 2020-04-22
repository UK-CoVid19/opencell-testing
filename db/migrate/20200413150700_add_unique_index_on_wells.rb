class AddUniqueIndexOnWells < ActiveRecord::Migration[5.2]
  def change
    add_index :wells, %i[row column plate_id], unique: true
  end
end
