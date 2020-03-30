class AddUidToPlate < ActiveRecord::Migration[5.2]
  def change
    add_column :plates, :uid, :string
    add_index :plates, :uid, unique: true
  end
end
