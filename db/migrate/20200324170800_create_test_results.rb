class CreateTestResults < ActiveRecord::Migration[5.2]
  def change
    create_table :test_results do |t|
      t.references :test, foreign_key: true
      t.references :well, foreign_key: true
      t.float :value

      t.timestamps
    end
  end
end
