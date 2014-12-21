defmodule Test.Transport do
  defstruct from: "",
            to: "",
            content: ""


  def start() do
    Agent.start_link(fn ->
      []
    end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn(_state) ->
      []
    end)
  end

  def send(from, to, composed_email) do
    mail_data = %Test.Transport{from: from, to: to, content: composed_email}

    Agent.update(__MODULE__, fn(state) ->
      [mail_data | state]
    end)
  end

  def get_mails do
    mails = Agent.get(__MODULE__, fn(state) -> state end)
  end
end