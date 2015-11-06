defmodule Mailer.Util do

  def get_domain(address) do
    addr = case String.split(address, ~r([<>])) do
      [_name, addr, ""] -> addr
      [addr] -> addr
    end
    [_, domain] = String.split(addr, "@")
    domain
  end
end
