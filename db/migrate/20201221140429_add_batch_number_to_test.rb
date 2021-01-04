class AddBatchNumberToTest < ActiveRecord::Migration[6.0]
  def change
    add_column :tests, :batch, :string
  end
end
