defmodule TwitterWeb.Router do
  use TwitterWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TwitterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  pipeline :graphql do
    plug AshGraphql.Plug
  end

  if Mix.env() == :dev do
    import AshAdmin.Router

    scope "/" do
      pipe_through :browser
      ash_admin("/admin")
    end
  end

  scope "/", TwitterWeb do
    pipe_through :browser

    ash_authentication_live_session :authentication_required,
      on_mount: {TwitterWeb.LiveUserAuth, :live_user_required} do
      live "/", TweetLive.Index, :index
      live "/tweets/new", TweetLive.Index, :new
      live "/tweets/:id/edit", TweetLive.Index, :edit

      live "/tweets/:id", TweetLive.Show, :show
      live "/tweets/:id/show/edit", TweetLive.Show, :edit
    end

    sign_in_route(register_path: "/register", reset_path: "/reset")

    sign_out_route AuthController
    auth_routes_for Twitter.Accounts.User, to: AuthController
    reset_route []
  end

  scope "/api" do
    pipe_through :api

    scope "/json" do
      forward "/swaggerui",
              OpenApiSpex.Plug.SwaggerUI,
              path: "/api/json/open_api",
              title: "Twitter's JSON-API - Swagger UI",
              default_model_expand_depth: 4

      forward "/redoc",
              Redoc.Plug.RedocUI,
              spec_url: "/api/json/open_api"

      forward "/", TwitterWeb.JsonApiRouter
    end

    scope "/gql" do
      pipe_through :graphql

      forward "/playground",
              Absinthe.Plug.GraphiQL,
              schema: Module.concat(["TwitterWeb.GraphqlSchema"]),
              interface: :playground

      forward "/", Absinthe.Plug, schema: Module.concat(["TwitterWeb.GraphqlSchema"])
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:twitter, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TwitterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
