class AddUserToRecord < ActiveRecord::Migration[5.2]
  def change
    add_reference :records, :user, foreign_key: true
  end
end
