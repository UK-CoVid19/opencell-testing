class AddDetailsToResults < ActiveRecord::Migration[6.0]
  def change
    add_column :test_results, :state, :integer
    add_column :test_results, :comment, :text
  end
end
