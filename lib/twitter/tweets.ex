defmodule Twitter.Tweets do
  use Ash.Domain,
    extensions: [AshJsonApi.Domain, AshAdmin.Domain]

  admin do
    show?(true)
  end

  json_api do
    prefix "/api/json"
  end

  resources do
  end
end
