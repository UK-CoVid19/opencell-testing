class AddUidIndexToSamples < ActiveRecord::Migration[5.2]
  def change
    add_index :samples, :uid, unique: true
  end
end
