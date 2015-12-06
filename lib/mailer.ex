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

      email = Mailer.compose_email(from: "from@example.com",
                                   to: "to@example.com",
                                   subject: "Subject",
                                   template: "welcome_template",
                                   data: template_data)

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

  The keyword list must contain the following parameters:
    `:from`, `:to`, `:subject`, `:template`, `:data`.

  The following parameters are optional:
    `:country_code`

  Default parameters can be specified in the application config:
      config :mailer,
        common_mail_params: [from: "Example <noreply@example.com>"]

  Given the that the templates are located in the location:

      priv/templates

  if the compose_email is called with a template named 'plain' it will look
  for the templates 'plain.txt' and 'plain.html' in location

      priv/templates/plain/

  If the template resolves to a single .txt file
  it will send a plain text email.

  If the template resolves to both .html and a .txt file
  it will send a multipart email.

  The template location can be internationalised by passing an optional
  country code. For example passing a country code of 'en' will modify
  the search path to:

      priv/templates/plain/en/
  """
  @spec compose_email(list({atom(), term})) :: Email.Plain.t | Email.Multipart.t

  def compose_email(params) when is_list(params) do
    final_params = Application.get_env(:mailer, :common_mail_params, [])
    |> Keyword.merge params

    compose_email(Keyword.get(final_params, :from),
                  Keyword.get(final_params, :to),
                  Keyword.get(final_params, :subject),
                  Keyword.get(final_params, :template),
                  Keyword.get(final_params, :data),
                  Keyword.get(final_params, :country_code, ""))
  end

  @doc """
  Compose an email to a recipient.

  Similar to compose_email/1, but with parameters supplied directly.
  Ignores default parameters from the application config.
  """
  def compose_email(from, to, subject, template, data, country_code \\ "") do
    case Mailer.Template.Locator.locate(template, country_code) do
      [] -> raise ArgumentError, message: "Template(s) not found: #{template}"
      templates -> compose_email_by_type(from, to, subject, templates, data)
    end
  end

  @doc false
  defp compose_email_by_type(from, to, subject, [{:text, plain}], data) do
    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)

    body = Mail.Renderer.render(plain, data)

    Plain.create
    |> Plain.add_from(from)
    |> Plain.add_to(to)
    |> Plain.add_subject(subject)
    |> Plain.add_message_id(Mailer.Message.Id.create(from))
    |> Plain.add_date(date)
    |> Plain.add_body(body)
  end

  @doc false
  defp compose_email_by_type(from, to, subject, [{:html, html}, {:text, plain}], data) do
    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)

    plain_text = Mail.Renderer.render(plain, data)
    html_text = Mail.Renderer.render(html, data)

    Multipart.create
    |> Multipart.add_from(from)
    |> Multipart.add_to(to)
    |> Multipart.add_subject(subject)
    |> Multipart.add_message_id(Mailer.Message.Id.create(from))
    |> Multipart.add_date(date)
    |> Multipart.add_text_body(plain_text)
    |> Multipart.add_html_body(html_text)
  end
end
