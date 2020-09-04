class AddControlToSample < ActiveRecord::Migration[6.0]
  def change
    add_column :samples, :control, :boolean, default: false
  end
end
