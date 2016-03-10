defmodule Mailer.Email.Plain.Test do
  use ExUnit.Case

  alias Mailer.Email.Plain
  alias Mailer.Util

  test "can set the from and domain fields" do
    email = Plain.create

    email = Plain.add_from(email, "test@example.com")

    assert "test@example.com" == email.from
    assert "example.com" == email.domain
  end

  test "can set to field" do
    email = Plain.create

    email = Plain.add_to(email, "one@example.com")

    assert ["one@example.com"] == email.to
  end

  test "can set the subject" do
    email = Plain.create

    email = Plain.add_subject(email, "welcome")

    assert "welcome" == email.subject
  end

  test "can set the body" do
    email = Plain.create

    email = Plain.add_body(email, "body")

    assert "body" == email.body
  end

  test "can set the message id" do
    email = Plain.create

    email = Plain.add_message_id(email, "123")

    assert "123" == email.message_id
  end

  test "can set the message date" do
    date = "today"
    email = Plain.create

    email = Plain.add_date(email, date)

    assert date == email.date
  end


  test "will compose the email" do
    date = Util.localtime_to_str
    email = Plain.create

    email = Plain.add_from(email, "from@example.com")
    email = Plain.add_to(email, "to@example.com")
    email = Plain.add_subject(email, "welcome")
    email = Plain.add_message_id(email, "123@example.com")
    email = Plain.add_date(email, date)
    email = Plain.add_body(email, "body")

    composed = {
                  "text", "plain",
                  [
                    {"From", "from@example.com"},
                    {"To", ["to@example.com"]},
                    {"Subject", "welcome"},
                    {"Message-ID", "123@example.com"},
                    {"MIME-Version", "1.0"},
                    {"Date", date}
                  ],
                  [
                    {"content-type-params"},
                    [
                      {"charset", "utf-8"}
                    ],
                    {"Content-Transfer-Encoding", "quoted-printable"},
                    {"disposition", "inline"}
                  ],
                  "body"
                }

    assert composed == Plain.compose(email)
  end

  test "will decompose the email" do
    date = Util.localtime_to_str
    email_src = Plain.create

    email_src = Plain.add_from(email_src, "from@example.com")
    email_src = Plain.add_to(email_src, "to@example.com")
    email_src = Plain.add_subject(email_src, "welcome")
    email_src = Plain.add_message_id(email_src, "123@example.com")
    email_src = Plain.add_date(email_src, date)
    email_src = Plain.add_body(email_src, "body")

    composed = Plain.compose(email_src)

    email_dst = Plain.decompose(composed)

    assert email_src == email_dst
  end
end
