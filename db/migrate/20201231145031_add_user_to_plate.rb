class AddUserToPlate < ActiveRecord::Migration[6.0]
  def up
    add_reference :plates, :user, null: true, foreign_key: false
    
    # plates = Plate.all
    # if !plates.empty?
    #   pwd = Devise.friendly_token.first(12)
    #   question = SecurityQuestion.find_or_create_by(name: 'Where were you born?', locale: :en)
    #   dummy_user = !User.all.any? ? User.create!(email: 'dummy@example.com', password: 'b]^$t&JF}?kN3Z5n', password_confirmation: 'b]^$t&JF}?kN3Z5n', role: User.roles[:staff], security_question: question, security_question_answer:"London") : User.first
    #   plates.each do |p|
    #     user = p.samples.first.records.where(state: Sample.states[:preparing]).first.user
    #     if user.nil?
    #       p.update(user: dummy_user)
    #     else
    #       p.update(user: user)
    #     end
    #     p.save!
    #   end
    #   sleep(5.seconds)
    # end
    # change_column_null :plates, :user_id, false
    # add_foreign_key :plates, :users

  end

  def down
    # remove_foreign_key :plates, :users
    remove_column :plates, :user_id, :integer
  end
end
