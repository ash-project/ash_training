# Lab 0 - Resources

## Relevant Documentation

- [Getting Started](https://hexdocs.pm/ash/get-started.html)
- [Attributes](https://hexdocs.pm/ash/attributes.html)
- [Domains](https://hexdocs.pm/ash/domains.html)
- [Ash.Resource.Info](https://hexdocs.pm/ash/Ash.Resource.Info.html)
- [Ash.Domain.Info](https://hexdocs.pm/ash/Ash.Domain.Info.html)
- [AshPostgres.DataLayer.Info](https://hexdocs.pm/ash_postgres/AshPostgres.DataLayer.Info.html)

## Context

We have already created a domain module for you, called `Twitter.Tweets` in `lib/twitter/tweets`.

## Steps

1. Run the following to generate a resource:

```bash
mix ash.gen.resource Twitter.Tweets.Tweet \
  --uuid-primary-key id \
  --default-actions read,destroy \
  --timestamps
```

This command

- adds a uuid primary key attribute to our resource
- adds a default read & destroy action
- adds the resource to the domain module `Twitter.Tweets`

2. Run `iex -S mix`, and use functions from `Ash.Resource.Info` to see that we've defined the resource properly. (ignore the warnings presented in iex)

```elixir
iex> Ash.Resource.Info.attributes(Twitter.Tweets.Tweet)
# [%Ash.Resource.Attribute{}]
```

```elixir
iex> Ash.Resource.Info.actions(Twitter.Tweets.Tweet)
# [%Ash.Resource.Read{}]
```

3. Add `Twitter.Tweets.Tweet` to our domain's (`Twitter.Tweets`) resource list. Ignore the extra content in the domain for module for now.

4. Use functions from `Ash.Domain.Info`

```elixir
iex> Ash.Domain.Info.resources(Twitter.Tweets)
# [...]
```

5. Run the following to add the `AshPostgres` extension to the resource:

```bash
mix ash.extend Twitter.Tweets.Tweet postgres
```

This command

- adds `data_layer: AshPostgres.DataLayer` to the `use Ash.Resource` statement
- configures a `repo` (`Twitter.Repo`)
- configures a `table`, inferred from the resource name, in this case `"tweets"`

```elixir
iex> AshPostgres.DataLayer.Info.table(Twitter.Tweets.Tweet)
# "tweets"
```

```elixir
iex> AshPostgres.DataLayer.Info.repo(Twitter.Tweets.Tweet)
# Twitter.Repo
```

## Try on your own

- Add a `:text` attribute to the `Tweet` resource, and check the `attributes` list with `Ash.Resource.Info` again.

- Change the table name to something else, and check the table name with `AshPostgres.DataLayer.Info` again.
