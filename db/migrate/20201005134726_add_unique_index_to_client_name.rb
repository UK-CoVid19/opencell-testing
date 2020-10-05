class AddUniqueIndexToClientName < ActiveRecord::Migration[6.0]
  def change
    add_index :clients, :name, unique: true
  end
end
