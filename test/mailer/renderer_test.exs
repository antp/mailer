defmodule Mailer.Renderer.Test do
  use ExUnit.Case

  test "it will render a template" do

    test_file = "#{System.cwd}" <> "/test/mailer/templates/plain/en/plain.txt"

    assert "Hello John Doe" == Mail.Renderer.render(test_file, [name: "John Doe"])
  end
end