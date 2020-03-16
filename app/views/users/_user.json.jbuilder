json.extract! user, :id, :name, :dob, :telno, :email, :created_at, :updated_at
json.url user_url(user, format: :json)
