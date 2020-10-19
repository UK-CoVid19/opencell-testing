class AddWebhookToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :url, :string
  end
end
