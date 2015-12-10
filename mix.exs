defmodule Mailer.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mailer,
      version: version,
      elixir: "~> 1.0",
      elixirc_paths: elixirc_paths(Mix.env),
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
    [applications: [:logger, :timex]]
  end

  def version do
    String.strip(File.read!("VERSION"))
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

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
      {:gen_smtp, "~> 0.9.0"},
      {:timex, "~> 1.0.0-rc3"},
      {:ex_doc, "~> 0.10", only: :dev},
      {:earmark, ">= 0.1.17", only: :dev}
    ]
  end

  defp description do
    """
    Mailer - A simple email client
    """
  end

  defp package do
    [
      files:        ["lib", "priv", "mix.exs", "README.md", "LICENCE.txt", "VERSION"],
      maintainers:  ["Antony Pinchbeck", "Yurii Rashkovskii", "Paul Scarrone", "sldab", "mogadget", "Miguel Martins", "Mike Janger", "Maxim Chernyak"],
      licenses:     ["apache 2 license"],
      links:        %{
                       "GitHub" => "https://github.com/antp/mailer",
                    }
    ]
  end
end
