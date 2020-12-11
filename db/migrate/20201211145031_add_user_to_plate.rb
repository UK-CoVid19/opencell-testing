class AddUserToPlate < ActiveRecord::Migration[6.0]
  def up
    add_reference :plates, :user, null: true, foreign_key: false
    Plate.all.each do |p|
      user = p.samples.first.records.where(state: Sample.states[:preparing]).user
      p.update(user: user)
      p.save!
    end
    change_column_null :plates, :user_id, false
    add_foreign_key :plates, :users

  end

  def down
    add_foreign_key :plates, :users
    remove_column :plates, :user_id, :integer
  end
end
