class AddLabToPlates < ActiveRecord::Migration[6.0]
  def change
    # add_reference :plates, :lab, null: true, foreign_key: true
    add_column :plates, :lab_id, :integer, null: true
    # add_foreign_key :plates, :lab_id
    group = Labgroup.find_or_create_by!(name: "Jersey")

    lab = Lab.find_or_create_by!(name: 'Jersey Airport')
    unless lab.labgroups.include? group
      lab.labgroups << group
      lab.save!
    end

    Plate.update_all(lab_id: lab.id)
    change_column_null :plates, :lab_id, false
    add_index :plates, :lab_id
  end
end
