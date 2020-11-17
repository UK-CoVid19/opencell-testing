class ChangeUniqueIndexOnSamplesToClientSpecific < ActiveRecord::Migration[6.0]
  def change
    remove_index :samples, [:uid, :is_retest]
    add_index :samples, [:uid, :is_retest, :client_id], unique: true
  end
end
