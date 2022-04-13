export PG_DB="aitech"
export PG_URL="postgres://postgres:secret@localhost:16001/${PG_DB}?sslmode=disable"
sudo docker run -d \
   -e POSTGRES_PASSWORD=secret \
   -e POSTGRES_DB="${PG_DB}" \
   --name ${PG_DB} \
   -p 16001:5432 \
   postgres

psql -d $PG_URL -f aitech-database.sql --quiet
psql -d $PG_URL -f aitech-roles.sql --quiet