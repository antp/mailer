defmodule Mailer.Email.Plain do
  defstruct type: :plain,
            from: "",
            domain: "",
            to: [],
            subject: "",
            headers: [],
            message_id: "",
            date: "",
            body: ""

  def create do
    %Mailer.Email.Plain{}
  end

  def add_from(email, from) do
    [_, domain] = String.split(from, "@")
    email = %{email | from: from}
    %{email | domain: domain}
  end

  def add_to(email, to) do
    %{email | to: [to | email.to]}
  end

  def add_subject(email, subject) do
    %{email | subject: subject}
  end

  def add_message_id(email, message_id) do
    %{email | message_id: message_id}
  end

  def add_date(email, date) do
    %{email | date: date}
  end

  def add_body(email, body) do
    %{email | body: body}
  end

  def compose(email) do
    {
      "text", "plain",
      [
        {"From", email.from},
        {"To", email.to},
        {"Subject", email.subject},
        {"Message-ID", email.message_id},
        {"MIME-Version", "1.0"},
        {"Date", email.date}
      ],
      [
        {"content-type-params"},
        [
          {"charset", "utf-8"},
        ],
        {"Content-Transfer-Encoding", "quoted-printable"},
        {"disposition", "inline"}
      ],
      email.body
    }
  end

  def decompose(msg) do
    {
      "text", "plain",
      [
        {"From", from},
        {"To", to},
        {"Subject", subject},
        {"Message-ID", msg_id},
        {"MIME-Version", "1.0"},
        {"Date", date}
      ],
      _,
      body
    } = msg

    [_, domain] = String.split(msg_id, "@")

    to = maybe_list(to)

    %Mailer.Email.Plain{from: from,
                        to: to,
                        subject: subject,
                        domain: domain,
                        message_id: msg_id,
                        date: date,
                        body: body
                      }
  end

  defp maybe_list(to) when is_list(to) do
    to
  end

  defp maybe_list(to) do
    [to]
  end

end
