class CreateRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :records do |t|
      t.references :sample, foreign_key: true
      t.string :note
      t.integer :state, null: false

      t.timestamps
    end
  end
end
