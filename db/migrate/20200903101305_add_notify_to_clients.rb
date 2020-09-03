class AddNotifyToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :notify, :boolean
  end
end
