defmodule Mailer.Email.Multipart do
  defstruct type: :multipart,
            from: "",
            domain: "",
            to: [],
            subject: "",
            headers: [],
            message_id: "",
            date: "",
            plain_text_body: "",
            html_text_body: ""

  def create do
    %Mailer.Email.Multipart{}
  end

  def add_from(email, from) do
    domain = Mailer.Util.get_domain(from)
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

  def add_text_body(email, body) do
    %{email | plain_text_body: body}
  end

  def add_html_body(email, body) do
    %{email | html_text_body: body}
  end

  def compose(email) do
    {
      "multipart", "alternative",
      [
        {"From", email.from},
        {"To", email.to},
        {"Subject", email.subject},
        {"Message-ID", email.message_id},
        {"MIME-Version", "1.0"},
        {"Date", email.date},
      ],
      [],
      [
        {"text","plain",
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
          email.plain_text_body
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
            {"disposition-params",[]}
          ],
          email.html_text_body
        }
      ]
    }
  end

  def decompose(msg) do
    {"multipart", "alternative",
      headers,
      _,
      [
        {"text","plain",
          _,
          _,
          plain_text_body
        },
        {"text", "html",
          _,
          _,
          html_text_body
        }
      ]
    } = msg


    email = %Mailer.Email.Multipart{}

    email = List.foldl(headers, email, fn(item, email) ->
      process_header(item, email)
    end)

    email = %{email | plain_text_body: plain_text_body}
    %{email | html_text_body: html_text_body}
  end

  defp process_header({"From", from}, email) do
    %{email | from: from}
  end

  defp process_header({"To", to}, email) do
    %{email | to: to}
  end

  defp process_header({"Subject", subject}, email) do
    %{email | subject: subject}
  end

  defp process_header({"Message-ID", msg_id}, email) do
    domain = Mailer.Util.get_domain(msg_id)

    email = %{email | message_id: msg_id}
    %{email | domain: domain}
  end

  defp process_header({"Date", date}, email) do
     %{email | date: date}
  end

  defp process_header(_, email) do
     email
  end
end
