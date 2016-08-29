defmodule Mailer.Message.Id do
  @variant10 2
  @uuid_v4 4
  @doc """
  Creates a uuid v4
  """
  def create(domain) do
    string_uuid = create_uuid
      |> uuid_to_string


    string_uuid <> "@" <> domain

  end

  def create_uuid do
    <<u0::48, _::4, u1::12, _::2, u2::62>> = :crypto.strong_rand_bytes(16)
    <<u0::48, @uuid_v4::4, u1::12, @variant10::2, u2::62>>
  end

  def uuid_to_string(<<u0::32, u1::16, u2::16, u3::16, u4::48>>) do
    :io_lib.format("~8.16.0b-~4.16.0b-~4.16.0b-~4.16.0b-~12.16.0b", [u0, u1, u2, u3, u4])
      |> to_string
  end
end
