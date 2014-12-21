use Mix.Config

config :mailer, :smtp_client,
  server: "127.0.0.1",
  port: 2525,
  hostname: "mailer",
  transport: :test

config :mailer, :smtp_server,
  server: "127.0.0.1",
  port: 2525,
  hostname: "mailer",
  handler: Test.Mail.Handler
