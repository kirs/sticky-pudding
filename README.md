# Sticky Pudding

Sticky Pudding is an app that demonstrates how to implement the Sticky Writer pattern in 50 lines of code.
It's based on PostgreSQL but nothing stops it from working with MySQL.

Check `app.rb` to learn how it works, and read the assiciated post.

## Setup

1. Install dependencies by running `bundle install`
2. Create Postgres master and replicas by running `NUM_REPLICAS=2 POSTGRES_PORT=5435 script/create_cluster`
3. Setup the database by running

```
createdb -p $POSTGRES_PORT sticky-pudding
psql -p $POSTGRES_PORT sticky-pudding << schema.sql
```

4. Start the app: `NUM_REPLICAS=2 POSTGRES_PORT=5434 ruby app.rb`
