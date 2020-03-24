class AddWellToSample < ActiveRecord::Migration[5.2]
  def change
    add_reference :samples, :well, foreign_key: true
  end
end
