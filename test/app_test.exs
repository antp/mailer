defmodule App.Test do
  use ExUnit.Case

  alias Mailer.Email.Plain
  alias Mailer.Email.Multipart

  setup_all do
    Test.Transport.start

    :ok
  end

  test "It will send plain text email" do

    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)
    email = Plain.create

    email = Plain.add_from(email, "from@example.com")
    email = Plain.add_to(email, "to@example.com")
    email = Plain.add_subject(email, "Plain")
    email = Plain.add_message_id(email, "123@example.com")
    email = Plain.add_date(email, date)
    email = Plain.add_body(email, "body")

    composed_email = Plain.compose(email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Test.Transport.clear
    Mailer.Smtp.Client.send(email.from, email.to, composed_email, server)

    [sent_email] = Test.Transport.get_mails

    assert email.from == sent_email.from
    assert email.to == sent_email.to
    assert true == String.contains?(sent_email.content, "Plain")
  end

  test "It will send multipart email" do

    date = Timex.Date.local
    date = Timex.DateFormat.format!(date, "%a, %d %b %Y %T %z", :strftime)
    email = Multipart.create

    email = Multipart.add_from(email, "from@example.com")
    email = Multipart.add_to(email, "to@example.com")
    email = Multipart.add_subject(email, "Multipart")
    email = Multipart.add_message_id(email, "123@example.com")
    email = Multipart.add_date(email, date)
    email = Multipart.add_text_body(email, "text body")
    email = Multipart.add_html_body(email, "<html><body>Html body</body></html>")

    composed_email = Multipart.compose(email)

    server = Mailer.Client.Cfg.create
    server = Mailer.Client.Cfg.to_options(server)

    Test.Transport.clear
    Mailer.Smtp.Client.send(email.from, email.to, composed_email, server)

    [sent_email] = Test.Transport.get_mails

    assert email.from == sent_email.from
    assert email.to == sent_email.to
    assert true == String.contains?(sent_email.content, "text body")
    assert true == String.contains?(sent_email.content, "Html body")
  end

end



# defmodule App.Test do
#   use ExUnit.Case

#   alias Mailer.Email.Plain
#   alias Mailer.Email.Multipart

#   setup_all do
#     server = Mailer.Server.Cfg.create
#     server = Mailer.Server.Cfg.to_options(server)

#     Mailer.Smtp.Server.start_link(server)
#     Test.Mail.Handler.start

#     template_location = "#{System.cwd}" <> "/test/mailer/templates"
#     Application.put_env(:mailer, :templates, template_location)

#     :ok
#   end

#   test "it will send plain text email" do
#     data = [name: "John Doe"]

#     email = Mailer.compose_email("from@example.com", "to@example.com", "Plain", "plain", data)

#     Mailer.send(email)

#     [{_id, raw_email}] = Test.Mail.Handler.get_mails

#     rxd_email = Plain.decompose(raw_email)

#     assert "Hello John Doe" == rxd_email.body
#   end

#   test "it will send multipart email" do
#     data = [name: "John Doe"]

#     email = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)

#     Mailer.send(email)

#     [{_id, raw_email}] = Test.Mail.Handler.get_mails

#     rxd_email = Multipart.decompose(raw_email)

#     assert "multipart plain John Doe" == rxd_email.plain_text_body
#     assert "multipart html John Doe" == rxd_email.html_text_body
#   end

# end