defmodule Mailer.Server.Cfg do
  defstruct server: "127.0.0.1",
            port: 1025,
            hostname: "mailer"

  def create do
    client_cfg = Application.get_env(:mailer, :smtp_server, [])

    List.foldl(client_cfg, %Mailer.Server.Cfg{}, fn ({k, v}, acc) ->
      case k do
        :server ->
           %{acc | server: v}
        :port ->
          %{acc | port: v}
        :hostname ->
          %{acc | hostname: v}
        _ ->
          acc
      end
    end)

  end

  def to_options(server_cfg) do
    [
      relay: server_cfg.server,
      port: server_cfg.port,
      hostname: server_cfg.hostname
    ]
  end
end