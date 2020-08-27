class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.string :name
      t.string :api_key_hash, index: true

      t.timestamps
    end

    remove_reference :samples, :user

    add_reference :samples, :client, foreign_key: true, index: true

  end
end
