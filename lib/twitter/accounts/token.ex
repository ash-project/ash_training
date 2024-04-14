defmodule Twitter.Accounts.Token do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication.TokenResource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Twitter.Accounts

  token do
    domain Twitter.Accounts
  end

  postgres do
    table "tokens"
    repo Twitter.Repo
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end

  actions do
    defaults [:read]
  end
end
