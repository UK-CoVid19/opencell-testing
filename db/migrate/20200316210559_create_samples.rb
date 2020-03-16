class CreateSamples < ActiveRecord::Migration[5.2]
  def change
    create_table :samples do |t|
      t.references :user, foreign_key: true
      t.integer :state

      t.timestamps
    end
  end
end
