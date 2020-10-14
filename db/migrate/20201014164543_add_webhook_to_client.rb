class AddWebhookToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :url, :string
    add_column :clients, :headers, :jsonb
  end
end
