class AddUniqueIndexOnHeaderKeyByClient < ActiveRecord::Migration[6.0]
  def change
    add_index :headers, [:key, :client_id], unique: true
  end
end
