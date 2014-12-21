defmodule Mailer.Smtp.Client do
  def send(from, to, content, server) do
    encoded = :mimemail.encode(content)


      server_cfg = Application.get_env(:mailer, :smtp_client)

      handler = List.foldr(server_cfg, nil, fn({k,v}, acc) ->
        case k do
          :transport ->
            v
          _ ->
            acc
        end
      end)

    do_send(handler, from, to, encoded, server)
  end

  defp do_send(:smtp, from, to, encoded, server) do
    :gen_smtp_client.send_blocking(
        {from,
        [to],
        encoded},
        server
      )
  end

  defp do_send(_, from, to, encoded, _server) do
    Test.Transport.send(from, to, encoded)
  end
end