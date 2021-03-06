# Sticky Pudding

<img width="360" src="https://user-images.githubusercontent.com/522155/34395849-c8fcbfb8-eb5b-11e7-80a1-52d8e82d4128.jpg">

Sticky Pudding is an app that demonstrates how to implement the Sticky Writer pattern in 50 lines of code.
It's using PostgreSQL adapter as an example but nothing stops it from working with MySQL.

Check `app.rb` to learn how it works, and read the assiciated post.

## Setup

1. Install dependencies by running `bundle install`
2. Create Postgres master and replica by running `POSTGRES_PORT=5435 script/create_cluster`
3. Setup the database by running

```
createdb -p $POSTGRES_PORT sticky-pudding
psql -p $POSTGRES_PORT sticky-pudding < schema.sql
```

4. Start the app: `POSTGRES_PORT=5434 ruby app.rb`
