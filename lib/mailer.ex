defmodule Mailer do
  alias Mailer.Email.Plain
  alias Mailer.Email.Multipart

  @moduledoc """
  A simple SMTP mailer.

  This can be used to send one off emails such welcome emails after signing up
  to a service or password recovery emails.

  # What it is not

  A mass mailer, just don't do it.

  # Example usage

  First compose an email with

      email = Mailer.compose("from@example.com", tp@example.com, "Subject", "welcome_template", template_data)

  Then send the email with

      response = Mailer.send(email)

  The response can be checked for failed deliveries.
  """

  @doc """
  Start the mailer application
  """
  # def start(_type, _args) do
  #   import Supervisor.Spec, warn: false

  #   children = [
  #     # Define workers and child supervisors to be supervised
  #     # worker(Mailer.Smtp.Server, [[port: 1025, address: {127,0,0,1}, domain: "test.example.com"]])
  #   ]

  #   # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
  #   # for other strategies and supported options
  #   opts = [strategy: :one_for_one, name: Mailer.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end

  @doc """
  Send a composed, email to the recipient
  """
  def send(%{type: :plain} = email) do
    composed_email = Plain.compose(email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Mailer.Smtp.Client.send(email.from, email.to, composed_email, server)
  end

  @doc """
  Send a composed, email to the recipient
  """
  def send(%{type: :multipart} = email) do
    composed_email = Multipart.compose(email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Mailer.Smtp.Client.send(email.from, email.to, composed_email, server)
  end

  @doc """
  Compose an email to a recipient.

  given the that the templates are located in the location:

      priv/templates

  if the compose_email is called with a template named 'plain' it will look
  for the templates 'plain.txt' and 'plain.html' in location

      priv/templates/plain/

  If the template resolves to a single .txt file
  it will send a plain text email.

  If the template resolves to both .html and a .txt file
  it will send a multipart email.

  The template location can be internationalised by passing an optional
  country code. for example passing a country code of 'en' will modify
  the search path to:

      priv/templates/plain/en/

  """
  def compose_email(from, to, subject, template, data, country_code \\ "") do
    templates = Mailer.Template.Locator.locate(template, country_code)

    compose_email_by_type(from, to, subject, templates, data)
  end

  @doc false
  defp compose_email_by_type(from, to, subject, [plain], data) do
    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)
    email = Plain.create

    body = Mail.Renderer.render(plain, data)

    email = Plain.add_from(email, from)
    email = Plain.add_to(email, to)
    email = Plain.add_subject(email, subject)
    email = Plain.add_message_id(email, Mailer.Message.Id.create(from))
    email = Plain.add_date(email, date)
    Plain.add_body(email, body)

  end

  @doc false
  defp compose_email_by_type(from, to, subject, [html, plain], data) do
    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)
    email = Multipart.create

    plain_text = Mail.Renderer.render(plain, data)
    html_text = Mail.Renderer.render(html, data)

    email = Multipart.add_from(email, from)
    email = Multipart.add_to(email, to)
    email = Multipart.add_subject(email, subject)
    email = Multipart.add_message_id(email, Mailer.Message.Id.create(from))
    email = Multipart.add_date(email, date)
    email = Multipart.add_text_body(email, plain_text)
    Multipart.add_html_body(email, html_text)

  end
end
