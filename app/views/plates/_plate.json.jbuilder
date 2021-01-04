json.id plate.id
json.created_at plate.created_at
json.updated_at plate.updated_at
json.status plate.status
json.wells plate.wells do |well|
  json.row well.row
  json.column well.column
  json.sample !well.sample.nil?
end
json.url plate_url(plate, format: :json)
