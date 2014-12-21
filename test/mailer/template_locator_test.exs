defmodule Mailer.Template.Locator.Test do
  use ExUnit.Case

  setup_all do
    template_location = "#{System.cwd}" <> "/test/mailer/templates"
    Application.put_env(:mailer, :templates, template_location)

    :ok
  end

  test "will locate a plain text template with a country code" do
    templates = Mailer.Template.Locator.locate("plain", "en")

    assert 1 == length(templates)
  end

  test "will locate a multipart template without country code" do
    templates = Mailer.Template.Locator.locate("multipart", "")

    assert 2 == length(templates)
  end

end