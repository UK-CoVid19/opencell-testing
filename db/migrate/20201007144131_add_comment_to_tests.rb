class AddCommentToTests < ActiveRecord::Migration[6.0]
  def change
    add_column :tests, :comment, :text
  end
end
