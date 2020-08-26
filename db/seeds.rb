# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

user = User.create!(email: 'staff@example.com', password: 'password', password_confirmation: 'password', role: User.roles[:staff]) if Rails.env.development?