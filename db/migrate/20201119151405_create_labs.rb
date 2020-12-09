class CreateLabs < ActiveRecord::Migration[6.0]
  def change
    create_table :labs do |t|
      t.string :name
      t.timestamps
    end
  end
end
