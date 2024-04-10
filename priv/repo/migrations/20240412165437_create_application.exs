defmodule Twitter.Repo.Migrations.CreateApplication do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:tweets, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :text, :text, null: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "tweets_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false
    end

    create table(:tokens, primary_key: false) do
      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false
      add :jti, :text, null: false, primary_key: true
    end

    create table(:likes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :user_id,
          references(:users,
            column: :id,
            name: "likes_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :tweet_id,
          references(:tweets,
            column: :id,
            name: "likes_tweet_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false
    end

    create unique_index(:likes, [:user_id, :tweet_id], name: "likes_unique_user_tweet_index")
  end

  def down do
    drop_if_exists unique_index(:likes, [:user_id, :tweet_id],
                     name: "likes_unique_user_tweet_index"
                   )

    drop constraint(:likes, "likes_user_id_fkey")

    drop constraint(:likes, "likes_tweet_id_fkey")

    drop table(:likes)

    drop table(:tokens)

    drop constraint(:tweets, "tweets_user_id_fkey")

    drop table(:tweets)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
