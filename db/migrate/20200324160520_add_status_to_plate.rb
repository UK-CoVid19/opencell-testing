class AddStatusToPlate < ActiveRecord::Migration[5.2]
  def change
    add_column :plates, :state, :integer, default: 0
  end
end
