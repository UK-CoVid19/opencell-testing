class CreateJoinTableLabgroupUser < ActiveRecord::Migration[6.0]
  def change
    create_join_table :labgroups, :users do |t|
      t.index [:labgroup_id, :user_id]
      t.index [:user_id, :labgroup_id]
    end
  end
end
