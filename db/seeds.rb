# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

question = SecurityQuestion.find_or_create_by!(name: 'Where were you born?', locale: :en)
unless AdminUser.find_by(email: 'admin@example.com')
  AdminUser.create!(email: 'admin@example.com', password: 'b]^$t&JF}?kN3Z5n', password_confirmation: 'b]^$t&JF}?kN3Z5n') if Rails.env.development?
end

labgroup = Labgroup.find_or_create_by!(name: 'Jersey')
unless User.find_by(email: 'staff@example.com')
  user = User.create!(email: 'staff@example.com', password: 'b]^$t&JF}?kN3Z5n', password_confirmation: 'b]^$t&JF}?kN3Z5n', role: User.roles[:staff], security_question: question, security_question_answer:"London", labgroups: [labgroup]) if Rails.env.development?
  user.confirm if Rails.env.development?
end

unless Client.find_by(name: 'testclient')
  client = Client.create!(name: 'testclient', api_key: "abcd1234", labgroup: labgroup) if Rails.env.development?
end

if user
  Sample.with_user(user) do
    4.times { |n| Sample.create(client: client, uid: n.to_s, state: Sample.states[:received]) } if Rails.env.development?
  end
end
