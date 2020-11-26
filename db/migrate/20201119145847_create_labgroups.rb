class CreateLabgroups < ActiveRecord::Migration[6.0]
  def change
    create_table :labgroups do |t|
      t.string :name

      t.timestamps
    end
    Labgroup.create(name: "Jersey")
  end
end
