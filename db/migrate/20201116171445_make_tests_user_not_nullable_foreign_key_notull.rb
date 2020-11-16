class MakeTestsUserNotNullableForeignKeyNotull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :tests, :user_id, false
  end
end
