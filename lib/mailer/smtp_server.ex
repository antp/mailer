defmodule Mailer.Smtp.Server do
  @behaviour :gen_smtp_server_session
  require Logger

  def start_link(server) do
    :gen_smtp_server.start_link(__MODULE__, [server])
  end

  def init(hostname, session_count, ip_address, options) do
    do_init(hostname, session_count, ip_address, options)
  end

  defp do_init(hostname, session_count, _ip_address, _options) when session_count > 20 do
    {:stop, :normal, ["421 #{hostname} is too busy to accept mail right now"]}
  end

  defp do_init(hostname, _session_count, _ip_address, _options) do
    {:ok, hostname, []}
  end

  def handle_HELO(_hostname, state) do
    {:ok, 655360, state}
  end

  @doc """
  Make extensions available
  """
  def handle_EHLO(_hostname, extensions, state) do
    # extensions = extensions ++ [{"AUTH", "PLAIN LOGIN CRAM-MD5"}, {"STARTTLS", true}]
    {:ok, extensions, state}
  end

  @doc """
  Check the from address
  """
  def handle_MAIL(_from, state) do
    {:ok, state}
  end

  def handle_MAIL_extension(_extension, state) do
    {:ok, state}
  end

  @doc """
  Check the recipient address
  """
  def handle_RCPT(_to, state) do
    {:ok, state}
  end

  def handle_RCPT_extension(_extension, state) do
    {:ok, state}
  end

  @doc """
  If we return ok, we've accepted responsibility for the email
  """
  def handle_DATA(_from, _to, data, state) do
    try do
      msg = :mimemail.decode(data)
      queued_as = Mailer.Message.Id.create_uuid
        |> Mailer.Message.Id.uuid_to_string

      server_cfg = Application.get_env(:mailer, :smtp_server)

      handler = List.foldr(server_cfg, nil, fn({k,v}, acc) ->
        case k do
          :handler ->
            v
          _ ->
            acc
        end
      end)

      maybe_save_msg(handler, queued_as, msg)

      {:ok, queued_as, state}
    catch
      e ->
        Logger.error("SMTP: Data error #{inspect e}")
        {:error, "501 Unable to decode the message", state}
    end
  end

  def maybe_save_msg(nil, _queued_as, _msg) do
    Logger.error("No SMTP handler set in configuration file.")
  end

  def maybe_save_msg(handler, queued_as, msg) do
    handler.save(queued_as, msg)
  end

  @doc """
  Reset the internal state of the connection
  """
  def handle_RSET(state) do
    state
  end

  @doc """
  Disable verification of email addresses
  """
  def handle_VRFY(_address, state) do
    {:error, "252 VRFY disabled by policy, just send some mail", state}
  end

  @doc """
  Only called if you add AUTH to the ESMTP extensions
  """
  def handle_AUTH(_type, _username, _password, state) do
    {:ok, state}
  end

  @doc """
  Only called if you add STARTTLS to the ESMTP extensions
  """
  def handle_STARTTLS(state) do
    state
  end

  def terminate(reason, state) do
    {:ok, reason, state}
  end

  def code_change(_oldVsn, state, _extra) do
    {:ok, state}
  end

  def handle_other(_verb, _args, state) do
    {["500 Error: Command not recognised"], state}
  end
end
