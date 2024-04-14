# Lab 10 - AshGraphql

## Relevant Documentation

- [AshGraphql Docs](https://hexdocs.pm/ash_graphql/1.0.0-rc.3/getting-started-with-graphql.html)

## Existing Setup

- GraphQL schema created
- Added to router, including playground

## Steps

1. Uncomment the contents of `TwitterWeb.GraphqlSchema`
2. Add `AshGraphql.Resource` to the extensions
3. Add the `graphql` DSL block

```elixir
graphql do
end
```

4. Add the type

```elixir
graphql do
  type :tweet
end
```

5. Add the `query` type

```elixir
graphql do
  type :tweet

  queries do
    list :feed, :feed
  end
end
```

Go to `localhost:4000/api/gql/playground`, and try the following query:

```graphql
query {
  feed{
    id
    text
    likeCount
    userEmail
  }
}
```

Browse the schema to see the kinds of things you can do, like filtering and sorting.

For example:

```graphql
query {
  feed(filter: {likeCount:{greaterThan: 0}}){
    id
    text
    likeCount
    userEmail
  }
}
```

## Try on your own

- Try out filtering/sorting in the GraphQL Playground

- Expose the `like` action over the GraphQL API, using the `mutations` configuration

- Expose the `unlike` action as well. (hint: you'll need to use `identity false` on the mutation)
