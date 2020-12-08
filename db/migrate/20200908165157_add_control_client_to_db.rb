class AddControlClientToDb < ActiveRecord::Migration[6.0]
  def change

    # unless Client.find_by(name: Client::CONTROL_NAME)
    #   Client.create!(name: Client::CONTROL_NAME, api_key:"666", notify: false)
    # end
    
  end
end
