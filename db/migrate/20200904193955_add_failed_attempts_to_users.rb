class AddFailedAttemptsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :failed_attempts, :integer, default: 0
  end
end
