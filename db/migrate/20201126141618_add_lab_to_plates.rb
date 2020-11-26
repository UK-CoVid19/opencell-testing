class AddLabToPlates < ActiveRecord::Migration[6.0]
  def change
    add_reference :plates, :lab, null: true, foreign_key: true
    lab = Lab.find_or_create_by(name: 'Jersey Airport')
    Plate.update_all(lab_id: lab.id)
    change_column_null :plates, :lab_id, false
  end
end
