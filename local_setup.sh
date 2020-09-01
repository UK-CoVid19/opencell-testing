docker-compose exec web rake db:create db:migrate
docker-compose exec web rake db:seed
docker-compose exec web rake db:create db:migrate RAILS_ENV=test