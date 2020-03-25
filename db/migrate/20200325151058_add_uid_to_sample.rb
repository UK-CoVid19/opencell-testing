class AddUidToSample < ActiveRecord::Migration[5.2]
  def change
    add_column :samples, :uid, :string, unique: true
  end
end
