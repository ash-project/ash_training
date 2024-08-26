defmodule Twitter.Tweets.Like do
  use Ash.Resource, otp_app: :twitter, domain: Twitter.Tweets, data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    timestamps()
  end

  actions do
    defaults [:read]

    create :like do
      accept [:tweet_id]
      change relate_actor(:user)
      upsert? true
      upsert_identity :unique_user_tweet
    end

    destroy :unlike do
      argument :tweet_id, :uuid, allow_nil?: false

      change filter expr(tweet_id == ^arg(:tweet_id) and user_id == ^actor(:id))
    end
  end

  identities do
    identity :unique_user_tweet, [:user_id, :tweet_id]
  end

  relationships do
    belongs_to :tweet, Twitter.Tweets.Tweet do
      allow_nil? false
    end

    belongs_to :user, Twitter.Accounts.User do
      allow_nil? false
    end
  end

  postgres do
    table "likes"
    repo Twitter.Repo

    references do
      reference :tweet, on_delete: :delete
    end
  end
end
