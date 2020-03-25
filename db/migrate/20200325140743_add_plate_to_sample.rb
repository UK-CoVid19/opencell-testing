class AddPlateToSample < ActiveRecord::Migration[5.2]
  def change
    add_reference :samples, :plate, foreign_key: true
  end
end
