defmodule Mail.Renderer do
  def render(template, data) do
    {:ok, file} = File.read(template)

    EEx.eval_string(file, assigns: data)
  end
end