defmodule Mail.Messaage.Id do
  def create(from_email) do
    [_, domain] = String.split(from_email, "@")

    id = Uuid.create()

    "#{id}@#{domain}"
  end
end