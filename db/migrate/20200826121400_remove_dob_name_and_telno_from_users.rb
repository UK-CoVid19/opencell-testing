class RemoveDobNameAndTelnoFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :name, :string
    remove_column :users, :dob, :date
    remove_column :users, :telno, :string
  end
end
