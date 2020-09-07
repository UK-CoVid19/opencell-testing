class DropValueFromTestResults < ActiveRecord::Migration[6.0]
  def change
    remove_column :test_results, :value, :float
  end
end
