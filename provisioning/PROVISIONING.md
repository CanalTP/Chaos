# Provisioning

Install docker by following instructions from [http://docs.docker.com/engine/installation/](http://docs.docker.com/engine/installation/)

## PostgreSQL

Build PostgreSQL image

```
(cd  provisioning/postgresql && sudo docker build -t postgresql .)
```

Run PostgresSQL container interactively to declare `postgres` user password

```
export POSTGRES_PASSWORD="%~\`4cj,\|@snhg!'f@ay~"
sudo docker run \
-v `pwd`/provisioning/postgresql/logs:/var/log/postgresql \
-v `pwd`/provisioning/postgresql/data:/var/lib/postgresql \
-ti -p 5432:5432 \
-e POSTGRES_PASS=$POSTGRES_PASSWORD postgresql /bin/bash

# from within the container shell
# run a PostgreSQL server in background
/scripts/run-postgresql.sh &
sudo -u postgres /scripts/create-postgresql-user-databases.sh
```

Run PostgresSQL container in background

```
export POSTGRES_PASSWORD="%~\`4cj,\|@snhg!'f@ay~"
sudo docker run \
-v `pwd`/provisioning/postgresql/logs:/var/log/postgresql \
-v `pwd`/provisioning/postgresql/data:/var/lib/postgresql \
-e POSTGRES_PASS=$POSTGRES_PASSWORD \
-d -p 5432:5432 postgresql
```
