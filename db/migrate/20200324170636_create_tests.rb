class CreateTests < ActiveRecord::Migration[5.2]
  def change
    create_table :tests do |t|
      t.references :plate, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
