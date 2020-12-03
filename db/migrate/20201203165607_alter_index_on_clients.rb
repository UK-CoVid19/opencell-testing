class AlterIndexOnClients < ActiveRecord::Migration[6.0]
  def change
    change_column_null :clients, :name, false
    remove_index :clients, :name
    add_index :clients, [ :name, :labgroup_id ], unique: true
    add_index :clients, :name

  end
end
