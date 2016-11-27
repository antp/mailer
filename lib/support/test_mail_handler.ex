defmodule Test.Mail.Handler do

  def start() do
    Agent.start(fn -> [] end, name: __MODULE__)
  end

  def clear do
    Agent.update(__MODULE__, fn(_state) -> [] end)
  end

  def save(id, raw_mail) do
    Agent.update(__MODULE__, fn(state) -> [{id, raw_mail} | state] end)
  end

  def get_mails do
    Agent.get(__MODULE__, fn(state) -> state end)
  end

end