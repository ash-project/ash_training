defmodule Twitter.Accounts do
  use Ash.Domain,
    extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource Twitter.Accounts.User
    resource Twitter.Accounts.Token
  end
end
