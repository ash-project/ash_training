# Lab 8 - AshJsonApi

## Relevant Documentation

- [AshJsonApi Docs](https://hexdocs.pm/ash_json_api/1.0.0-rc.3/getting-started-with-json-api.html)

## Existing Setup

- JSON API router created
- Domain configured with `prefix`

## Steps

1. Add `AshJsonApi.Resource` to the extensions
2. Add the `json_api` block

```elixir
json_api do
end
```

3. Add the type

```elixir
json_api do
  type :tweet
end
```

4. Add the routes block, and a base route

```elixir
json_api do
  type :tweet

  routes do
  end
end
```

5. Add the base route

```elixir
json_api do
  type :tweet

  routes do
    base "/tweets"
  end
end
```

6. Add an `index` route

```elixir
json_api do
  type :tweet

  routes do
    base "/tweets"

    index :feed
  end
end
```

### Try on your own

- Try out the api at `localhost:4000/api/json/tweets/feed`
- Check out the swagger docs at `localhost:4000/api/json/swaggerui`
- Check out the redoc docs at `localhost:4000/api/json/redoc`
