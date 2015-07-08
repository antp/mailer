defmodule Mailer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mailer,
      version: version,
      elixir: "~> 1.0.0",
      deps: deps,
      description: description,
      package: package,
      name: "Mailer",
      source_url: "https://github.com/antp/mailer"
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :iconv]]
  end

  def version do
    String.strip(File.read!("VERSION"))
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:gen_smtp, github: "vagabond/gen_smtp"},
      {:iconv, github: "antp/erlang-iconv"},
      {:timex, github: "bitwalker/timex"},
      {:ex_doc, "~> 0.6", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Mailer - A simple email client
    """
  end

  defp package do
    [
      files:        ["lib", "priv", "mix.exs", "README.md", "LICENCE.txt"],
      contributors: ["Antony Pinchbeck", "Yurii Rashkovskii", "Paul Scarrone"],
      licenses:     ["apache 2 license"],
      links:        %{
                       "GitHub" => "https://github.com/antp/mailer",
                    }
    ]
  end
end
