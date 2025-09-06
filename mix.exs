defmodule LogProb.MixProject do
  use Mix.Project

  def project do
    [
      app: :logprob,
      version: "0.1.0",
      elixir: "~> 1.2",
      start_permanent: Mix.env() == :prod,
      description: "Log probabilities made simple",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.3"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Matt Sutton"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mhsdef/logprob"}
    ]
  end
end
