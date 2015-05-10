defmodule Mailer.Template.Locator do

  def locate(template_name, country_code) do
    template_location = Application.get_env(:mailer, :templates)
      |> Path.join(template_name)
      |> Path.join(country_code)
      |> Path.join("#{template_name}.*")

    Path.wildcard(template_location)
  end
end
