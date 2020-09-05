# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
AdminUser.create!(email: 'admin@example.com', password: 'b]^$t&JF}?kN3Z5n', password_confirmation: 'b]^$t&JF}?kN3Z5n') if Rails.env.development?

user = User.create!(email: 'staff@example.com', password: 'b]^$t&JF}?kN3Z5n', password_confirmation: 'b]^$t&JF}?kN3Z5n', role: User.roles[:staff]) if Rails.env.development?
user.confirm if Rails.env.development?

client = Client.create!(name: 'testclient', api_key: "abcd1234") if Rails.env.development?

control_client = Client.create!(name: Client::CONTROL_NAME, api_key:"666", notify: false)

Sample.with_user(user) do
    4.times { |n| Sample.create(client: client, uid: n.to_s, state: Sample.states[:requested]) } if Rails.env.development?
end
