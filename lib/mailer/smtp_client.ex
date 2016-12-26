defmodule Mailer.Smtp.Client do
  def send(from, to, content, server) do
    # remove empty cc and bcc headers which can cause errors in encoding
    headers = Enum.reject(elem(content, 2), fn {k, v} -> k in ["Cc", "Bcc"] and v == [] end)
    content = put_elem(content, 2, headers)
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
