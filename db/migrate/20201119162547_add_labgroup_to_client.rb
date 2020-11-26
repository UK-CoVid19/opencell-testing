class AddLabgroupToClient < ActiveRecord::Migration[6.0]
  def change
    group = Labgroup.find_or_create_by(name: "Jersey")
    add_reference :clients, :labgroup, null: true, foreign_key: true
    Client.update_all(labgroup_id: group.id)
    change_column_null :clients, :labgroup_id, false
  end
end
