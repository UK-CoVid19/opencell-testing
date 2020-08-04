# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!


ActionMailer::Base.smtp_settings = {
    :user_name => 'onlythebestevents',
    :password =>  Rails.application.credentials.dig(:sendgrid_password),
    :domain => 'https://arcane-island-35232.herokuapp.com/',
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}
