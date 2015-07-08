defmodule App.Test do
  use ExUnit.Case

  alias Mailer.Email.Plain
  alias Mailer.Email.Multipart

  setup_all do
    Test.Transport.start

    template_location = "#{System.cwd}" <> "/test/mailer/templates"
    Application.put_env(:mailer, :templates, template_location)
    :ok
  end

  test "It will send plain text email" do

    data = [name: "John Doe"]
    composed_email = Mailer.compose_email("from@example.com", "to@example.com", "Plain", "plain", data)

    composed_email = Plain.compose(composed_email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Test.Transport.clear
    Mailer.Smtp.Client.send("from@example.com", "to@example.com", composed_email, server)

    [sent_email] = Test.Transport.get_mails

    assert true == String.contains?(sent_email.content, "John Doe")
  end

  test "It will send multipart email" do

    data = [name: "John Doe"]
    composed_email = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)

    composed_email = Multipart.compose(composed_email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Test.Transport.clear
    Mailer.Smtp.Client.send("from@example.com", "to@example.com", composed_email, server)

    [sent_email] = Test.Transport.get_mails
    
    assert true == String.contains?(sent_email.content, "text/plain")
    assert true == String.contains?(sent_email.content, "text/html")
  end

end



# defmodule App.Test do
#   use ExUnit.Case
#
#   alias Mailer.Email.Plain
#   alias Mailer.Email.Multipart
#
#   setup_all do
#     server = Mailer.Server.Cfg.create
#     server = Mailer.Server.Cfg.to_options(server)
#
#     Mailer.Smtp.Server.start_link(server)
#     Test.Mail.Handler.start
#
#     template_location = "#{System.cwd}" <> "/test/mailer/templates"
#     Application.put_env(:mailer, :templates, template_location)
#
#     :ok
#   end
#
#   test "it will send plain text email" do
#     data = [name: "John Doe"]
#
#     email = Mailer.compose_email("from@example.com", "to@example.com", "Plain", "plain", data)
#
#     Mailer.send(email)
#
#     [{_id, raw_email}] = Test.Mail.Handler.get_mails
#
#     rxd_email = Plain.decompose(raw_email)
#
#     assert "Hello John Doe" == rxd_email.body
#   end
#
#   test "it will send multipart email" do
#     data = [name: "John Doe"]
#
#     email = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)
#
#     Mailer.send(email)
#
#     [{_id, raw_email}] = Test.Mail.Handler.get_mails
#
#     rxd_email = Multipart.decompose(raw_email)
#
#     assert "multipart plain John Doe" == rxd_email.plain_text_body
#     assert "multipart html John Doe" == rxd_email.html_text_body
#   end
#
# end
