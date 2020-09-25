class ChangeIndicesOnSamples < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :is_retest, :boolean, default: false, null: false
    remove_index :samples, :uid
    add_index :samples, :uid
    add_index :samples, [:uid, :is_retest], unique: true
  end
end
