# Lab 9 - AshJsonApi

## Relevant Documentation

- [AshJsonApi Docs](https://hexdocs.pm/ash_json_api/getting-started-with-ash-json-api.html)

## Existing Setup

- JSON API router created

## Steps

1. Add `AshJsonApi.Resource` to the extensions to `Twitter.Tweets.Tweet`

```bash
mix ash.extend Twitter.Tweets.Tweet json_api
```

2. Add the json api type to the resource

```elixir
json_api do
  type "tweet"
end
```

3. Add the extension and an index route to the `Twitter.Tweets` domain

```elixir
  use Ash.Domain,
    extensions: [AshJsonApi.Domain]

json_api do
  routes do
    base_route "/tweets", Twitter.Tweets.Tweet do
      index :feed
    end
  end
end
```

4. Visit `localhost:4000/api/json/tweets`. You might notice that the `attributes` key is empty. This is because we haven't marked any of our attributes is `public?`.

For an API extension to show any attributes, calculations, they must be marked `public?`. Add the `public? true` option to the attributes on the `tweet`.

5. You'll notice also that the `links` are empty. We can add a `get` route to fetch a tweet.

```elixir
get :read, primary?: true
```

This `primary? true` causes the `links` to use this route as the `self` link for any given tweet.

### Try on your own

- Try out the api at `localhost:4000/api/json/tweets`
- Check out the swagger docs at `localhost:4000/api/json/swaggerui`
- Check out the redoc docs at `localhost:4000/api/json/redoc`
- Add a `description` to one of the attributes to see how it populates in the autogenerated documentation.
- Add a `description` to the action, and to the resource as well.

**_TIP_**: For resources, the `description` is added inside of the `resource` block.

```elixir
resource do
  description "your_description"
end
```
