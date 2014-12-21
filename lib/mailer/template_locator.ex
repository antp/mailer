defmodule Mailer.Template.Locator do

  def locate(template_name, country_code) do
    template_loacation = Application.get_env(:mailer, :templates)
    template_loacation = Path.join(template_loacation, template_name)
    template_loacation = Path.join(template_loacation, country_code)
    template_loacation = Path.join(template_loacation, "#{template_name}.*")

    Path.wildcard(template_loacation)
  end
end