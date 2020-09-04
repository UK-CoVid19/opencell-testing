class AddStateIndexToPlatesAndSamples < ActiveRecord::Migration[6.0]
  def change
    add_index :plates, :state
    add_index :samples, :state
  end
end
