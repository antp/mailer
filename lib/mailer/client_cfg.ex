defmodule Mailer.Client.Cfg do
  defstruct server: "127.0.0.1",
            port: 1025,
            hostname: "mailer",
            transport: :smtp,
            username: nil,
            password: nil,
            tls: :if_available, # always, never, if_available
            ssl: :false, # true or flase
            auth: :if_available,
            retries: 1

  def create do

    client_cfg = Application.get_env(:mailer, :smtp_client, [])

    List.foldl(client_cfg, %Mailer.Client.Cfg{}, fn ({k, v}, acc) ->
      case k do
        :server ->
           %{acc | server: v}
        :port ->
          %{acc | port: v}
        :hostname ->
          %{acc | hostname: v}
        :transport ->
          %{acc | transport: v}
        :username ->
          %{acc | username: v}
        :password ->
          %{acc | password: v}
        :ssl ->
          %{acc | ssl: v}
        :tls ->
          %{acc | tls: v}
        :auth ->
          %{acc | auth: v}
        :retries ->
          %{acc | retries: v}
      end
    end)
  end

  def to_options(client_cfg) do
    [
      relay: client_cfg.server,
      port: client_cfg.port,
      hostname: client_cfg.hostname,
      username: client_cfg.username,
      password: client_cfg.password,
      ssl: client_cfg.ssl,
      tls: client_cfg.tls,
      auth: client_cfg.auth,
      retries: client_cfg.retries
    ]
  end
end
