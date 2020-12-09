class CreateLabsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :labgroups, :labs do |t|
      t.index %i[labgroup_id lab_id]
      t.index %i[lab_id labgroup_id]
    end
  end
end
