class AddUserToPlate < ActiveRecord::Migration[6.0]
  def up
    add_reference :plates, :user, null: true, foreign_key: false
    pwd = Devise.friendly_token.first(12)
    dummy_user = !User.all.any? ? User.create(email: 'dummy@user.com', password: pwd, password_confirmation: pwd, api_key:SecureRandom.base64(16)) : User.first
    Plate.all.each do |p|
      user = p.samples.first.records.where(state: Sample.states[:preparing]).first.user
      if user.nil?
        p.update(user: dummy_user)
      else
        p.update(user: user)
      end
      p.save!
    end
    sleep(5.seconds)
    change_column_null :plates, :user_id, false
    add_foreign_key :plates, :users

  end

  def down
    remove_foreign_key :plates, :users
    remove_column :plates, :user_id, :integer
  end
end
