defmodule App.Test do
  use ExUnit.Case

  setup_all do
    Test.Transport.start

    template_location = "#{System.cwd}" <> "/test/mailer/templates"
    Application.put_env(:mailer, :templates, template_location)
    :ok
  end

  test "It will send plain text email" do

    data = [name: "John Doe"]
    composed_email = Mailer.compose_email("from@example.com", "to@example.com", "Plain", "plain", data)

    Test.Transport.clear
    Mailer.send(composed_email)

    [sent_email] = Test.Transport.get_mails

    assert true == String.contains?(sent_email.content, "John Doe")
  end

  test "It will send multipart email" do

    data = [name: "John Doe"]
    composed_email = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)

    Test.Transport.clear
    Mailer.send(composed_email)

    [sent_email] = Test.Transport.get_mails

    assert true == String.contains?(sent_email.content, "text/plain")
    assert true == String.contains?(sent_email.content, "text/html")
  end

  test "It will compose the same email with compose_email/1 and compose_email/6" do

    data = [name: "John Doe"]

    email1 = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)
    |> Map.delete(:message_id)

    email2 = Mailer.compose_email(from: "from@example.com",
                                  to: "to@example.com",
                                  subject: "Multipart",
                                  template: "multipart",
                                  data: data)
    |> Map.delete(:message_id)

    assert email1 == email2
  end

  test "It will take common_mail_params for compose_email/1" do

    data = [name: "John Doe"]

    Application.put_env(:mailer, :common_mail_params, [from: "from@example.com",
                                                       subject: "Multipart",
                                                       template: "multipart"])

    email1 = Mailer.compose_email("from@example.com", "to@example.com", "Multipart", "multipart", data)
    |> Map.delete(:message_id)

    email2 = Mailer.compose_email(to: "to@example.com", data: data)
    |> Map.delete(:message_id)

    assert email1 == email2
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
