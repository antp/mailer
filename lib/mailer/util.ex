defmodule Mailer.Util do

  def localtime_to_str() do
    date = Timex.DateTime.local
    Timex.format!(date, "{RFC822}")
  end

  def get_domain(address) do
    addr = case String.split(address, ~r([<>])) do
      [_name, addr, ""] -> addr
      [addr] -> addr
    end
    [_, domain] = String.split(addr, "@")
    domain
  end
end
