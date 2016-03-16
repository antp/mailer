defmodule Mailer.Email.Multipart.Test do
  use ExUnit.Case

  alias Mailer.Email.Multipart, as: Email
  alias Mailer.Util

  test "can set the from and domain fields" do
    email = Email.create

    email = Email.add_from(email, "test@example.com")

    assert "test@example.com" == email.from
    assert "example.com" == email.domain
  end

  test "can set to field" do
    email = Email.create

    email = Email.add_to(email, "one@example.com")

    assert ["one@example.com"] == email.to
  end

  test "can set the subject" do
    email = Email.create

    email = Email.add_subject(email, "welcome")

    assert "welcome" == email.subject
  end

  test "can set the message id" do
    email = Email.create

    email = Email.add_message_id(email, "123")

    assert "123" == email.message_id
  end

  test "can set the message date" do
    date = "today"
    email = Email.create

    email = Email.add_date(email, date)

    assert date == email.date
  end

  test "can set the plain text body" do
    email = Email.create

    email = Email.add_text_body(email, "text body")

    assert "text body" == email.plain_text_body
  end

  test "can set the html text body" do
    email = Email.create

    email = Email.add_html_body(email, "html body")

    assert "html body" == email.html_text_body
  end

  test "will compose the email" do
    date = Util.localtime_to_str

    email = Email.create

    email = Email.add_from(email, "from@example.com")
    email = Email.add_to(email, "to@example.com")
    email = Email.add_subject(email, "welcome")
    email = Email.add_message_id(email, "123@example.com")
    email = Email.add_date(email, date)
    email = Email.add_text_body(email, "text body")
    email = Email.add_html_body(email, "html body")


composed = {"multipart", "alternative",
              [
                  {"From", "from@example.com"},
                  {"To", ["to@example.com"]},
                  {"Subject", "welcome"},
                  {"Message-ID", "123@example.com"},
                  {"MIME-Version", "1.0"},
                  {"Date", date}
              ],
              [],
              [
                {"text", "plain",
                  [],
                  [
                    {"content-type-params",
                      [
                        {"charset", "utf8"},
                        {"format", "flowed"}
                      ]
                    },
                    {"disposition", "inline"},
                    {"disposition-params", []}
                  ],
                  "text body"
                },
                {"text", "html",
                  [],
                  [
                    {"content-type-params",
                      [
                        {"charset", "utf8"}
                      ]
                    },
                    {"disposition", "inline"},
                    {"disposition-params", []}
                  ],
                  "html body"
                }
              ]
            }

    assert composed == Email.compose(email)
  end

  test "will decompose the email" do
    date = Util.localtime_to_str
    email_src = Email.create

    email_src = Email.add_from(email_src, "from@example.com")
    email_src = Email.add_to(email_src, "to@example.com")
    email_src = Email.add_subject(email_src, "welcome")
    email_src = Email.add_message_id(email_src, "123@example.com")
    email_src = Email.add_date(email_src, date)
    email_src = Email.add_text_body(email_src, "text body")
    email_src = Email.add_html_body(email_src, "html body")

    composed = Email.compose(email_src)
    email_dst = Email.decompose(composed)

    assert email_src == email_dst
  end
end