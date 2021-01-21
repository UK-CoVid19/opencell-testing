class Addisactivetouser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :is_active, :boolean, default: true
  end
end
