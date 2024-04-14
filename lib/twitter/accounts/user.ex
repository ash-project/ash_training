defmodule Twitter.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshAdmin.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Twitter.Accounts

  admin do
    actor?(true)
  end

  postgres do
    table "users"
    repo Twitter.Repo
  end

  authentication do
    strategies do
      password :password do
        identity_field :email
      end
    end

    tokens do
      token_resource Twitter.Accounts.Token
      signing_secret Twitter.Accounts.Secrets
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string do
      allow_nil? false
      sensitive? true
    end
  end

  actions do
    defaults [:read]
  end

  identities do
    identity :unique_email, [:email]
  end
end
