# Mailer

A simple SMTP mailer.

This can be used to send one off emails such welcome emails after signing up
to a service or password recovery emails.

Mailer is built upon ```gen_smtp``` and uses it to deliver emails. 

## What it is not

A mass mailer, just don't do it.


## Dependencies
Add the following to your applications dependency block in ```mix.exs```.

```elixir
  {:mailer, github: "antp/mailer"}
```

Then run ```mix deps.get```.

Mailer uses ```gen_smtp``` to provide the mailing infrastructure.

## Usage

First compose an email with:

```elixir
  email = Mailer.compose_email("from@example.com", "to@example.com", "Subject", "welcome_template", template_data)
```

Then send the email with:

```elixir
   response = Mailer.send(email)
```

The response can be checked for failed deliveries.

Successful deliveries will have OK in the response such as:

```
"2.0.0 Ok: queued as 955CBC01C2\r\n"
```

Failed deliveries will have a response similar to:

```
{:error, :retries_exceeded,
 {:network_failure, "xxx.xxx.xxx.xxx", {:error, :ehostunreach}}}
```

### Configuration
In your applications ```config.exs``` file you need to add two sections.

#### Template configuration
Add a section to detail the location of the templates

```elixir
  config :mailer,
    templates: "priv/templates"
```

The mailer will look for all templates under this path. If you pass 'welcome' as the template name, mailer will look in ```priv/templates/welcome``` to locate the template file.

The path is relative to the directory that the application is run from. For a normal application setting ```priv/templates``` is correct. If you're application is part of an umbrella application then you will need to set it to the path within the ```apps``` directory such as:

```elixir
  config :mailer,
    templates: "apps/site_mailer/priv/templates"
```
if you run your application from the main umbrella directory.

#### SMTP client configuration
As mailer uses ```gen_smtp``` it requires a server to relay mails through.

The smtp configuration is passed through to ```gen_smtp```, so all options that ```gen_smtp``` supports are available.

Option:       | Values:
------------- | -------------
server        | Address of the email server to relay through.
hostname      | Hostname of your mail client
transport     | :smtp -> deliver mail using smtp (default)<br /> :test -> deliver mail to a test server
username      | username to use in authentication
password      | password for the username
tls           | :always -> always use TLS<br />:never -> never use TLS<br />:if_available -> use TLS if available (default)
ssl           | :true -> use SSL<br />:false -> do not use SSL (default)
auth          | :if_available -> use authentication if available (default)
retries       | Number of retries before a send failure is reported<br /> defaults to 1


## Plain text or Multipart email
Mailer will automatically send multipart emails if you have both a ```.txt``` and ```.html``` in the template directory. The ```.html``` template is optional.

### To send a welcome email:
Sending plain text only:

```elixir
priv/templates/welcome/welcome.txt
```

Sending a multipart email:

```elixir
priv/templates/welcome/welcome.txt
priv/templates/welcome/welcome.html
```

## Internationalisation
When sending a mail it is possible to add a country code. When the mail is composed this will be added to the template path to further qualify the template lookup.

If for example to wanted to support both English and French the template directory structure would look like the following:

```elixir
priv/templates/welcome/en/welcome.txt
priv/templates/welcome/en/welcome.html
priv/templates/welcome/fr/welcome.txt
priv/templates/welcome/fr/welcome.html
```
By including the country code in the compose call, Mailer will render the correct localised template.

```elixir
Mailer.compose_email("from@example.com", "to@example.com", "Subject", "welcome", data, "en")
```

# Author

Copyright © 2014 Component X Software, Antony Pinchbeck

Released under Apache 2 License
