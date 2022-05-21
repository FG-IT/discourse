#!/bin/bash
set -e

RETRIES=5

until psql -U $POSTGRES_USER -d $POSTGRES_DB -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
  echo "Waiting for postgres server, $((RETRIES--)) remaining attempts..."
  sleep 3
done

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER ${DISCOURSE_DB_USERNAME};
    ALTER USER ${DISCOURSE_DB_USERNAME} WITH PASSWORD '${DISCOURSE_DB_PASSWORD}';
    CREATE DATABASE ${DISCOURSE_DB_NAME};
    GRANT ALL PRIVILEGES ON DATABASE ${DISCOURSE_DB_NAME} TO ${DISCOURSE_DB_USERNAME};
EOSQL