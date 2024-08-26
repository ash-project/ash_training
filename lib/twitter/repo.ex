defmodule Twitter.Repo do
  use AshPostgres.Repo, otp_app: :twitter

  def installed_extensions do
    ["citext", "ash-functions"]
  end

  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
