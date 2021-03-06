defmodule ExAwsCodeDeploy.MixProject do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :ex_aws_code_deploy,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      source_url: "https://github.com/fmcgeough/ex_aws_code_deploy",
      homepage_url: "https://github.com/fmcgeough/ex_aws_code_deploy",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sweet_xml, "~> 0.6", optional: true},
      {:hackney, "1.6.3 or 1.6.5 or 1.7.1 or 1.8.6 or ~> 1.9", only: [:dev, :test]},
      {:poison, ">= 1.2.0", optional: true},
      {:ex_doc, "~> 0.19.2", only: [:dev, :test]},
      {:ex_aws, "~> 2.0"},
      {:dialyxir, "~> 0.5", only: [:dev]}
    ]
  end

  defp package do
    [
      description: "AWS Code Deploy service for ex_aws",
      maintainers: ["Frank McGeough"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/fmcgeough/ex_aws_code_deploy"}
    ]
  end
end
