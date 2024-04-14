# Lab 0 - Resources

## Relevant Documentation

- [Attributes](https://hexdocs.pm/ash/3.0.0-rc.21/attributes.html)
- [Domains](https://hexdocs.pm/ash/3.0.0-rc.21/domains.html)
- [Ash.Resource.Info](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Resource.Info.html)
- [Ash.Domain.Info](https://hexdocs.pm/ash/3.0.0-rc.21/Ash.Domain.Info.html)
- [AshPostgres.DataLayer.Info](https://hexdocs.pm/ash_postgres/2.0.0-rc.7/AshPostgres.DataLayer.Info.html)

## Steps

1. Define the `Twitter.Tweets.Tweet` resource in `lib/twitter/tweets/tweet.ex`

2. Add a `uuid_primary_key` attribute.

3. Add a simple read action

4. Use functions from `Ash.Resource.Info` to see in `iex` to see that we've defined the resource properly

```elixir
Ash.Resource.Info.attributes(Twitter.Tweets.Tweet)
# [%Ash.Resource.Attribute{}]

Ash.Resource.Info.actions(Twitter.Tweets.Tweet)
# [%Ash.Resource.Read{}]
```

5. Add `Twitter.Tweets.Tweet` to our domain module's resource list

6. Use functions from `Ash.Domain.Info`

```elixir
Ash.Domain.Info.resources(Twitter.Tweets)
```

7. Make the `Tweet` resource use `AshPostgres.DataLayer`, and configure it to use the `"tweets"` table, and the `Twitter.Repo` repo. We can check our configuration with `AshPostgres.DataLayer.Info`

```elixir
Ash.Postgres.DataLayer.Info.table(Twitter.Tweets.Tweet)
# "tweets"

Ash.Postgres.DataLayer.Info.repo(Twitter.Tweets.Tweet)
# Twitter.Repo
```

8. To check out the whole data structure for a resource, do this in `iex`

```elixir
Twitter.Tweets.Tweet.spark_dsl_config()
```

## Try on your own

- Add a `:text` attribute to the `Tweet` resource, and check the attributes list again.

- Change the table name to something else, and check the table name again.

- Make your own resource, adding it to the Tweets domain. See it show up in the domain's resources list.
