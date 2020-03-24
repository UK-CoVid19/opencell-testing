class CreateWells < ActiveRecord::Migration[5.2]
  def change
    create_table :wells do |t|
      t.string :row
      t.integer :column
      t.references :plate, foreign_key: true

      t.timestamps
    end
  end
end
