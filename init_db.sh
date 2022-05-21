#!/bin/bash

docker-compose up -d db
docker exec crossmap-community-db /bin/bash /pg/init_pq.sh
docker-compose down

docker-compose up -d app
docker exec crossmap-community-app /bin/bash -c "cd /app && bundle exec rails db:migrate && bundle exec rails assets:precompile"
docker-compose down
