class DropApiKeyFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :api_key
  end
end
