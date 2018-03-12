defmodule ExAwsCodeDeploy.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_aws_code_deploy,
      version: "2.0.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, ">= 0.0.0", only: [:dev, :test]},
      {:sweet_xml, ">= 0.0.0", only: [:dev, :test]},
      {:poison, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: [:dev, :test]},
      {:ex_aws, "~> 2.0"}
    ]
  end
end
