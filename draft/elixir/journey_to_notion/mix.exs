defmodule JourneyToNotion.MixProject do
  use Mix.Project



  def project do
    [
      app: :journey_to_notion,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :jason, :dotenv]
      # extra_applications: [:logger, :jason]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.8"},
      {:dotenv, "~> 3.0"},
      {:mogrify, "~> 0.9.1"},
      {:porcelain, "~> 2.0"},
      {:timex, "~> 3.7"},
    ]
  end
end
