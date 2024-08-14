# AWS CodeDeploy API

AWS Code Deploy Service module for [ex_aws](https://github.com/ex-aws/ex_aws).

## Installation

The package can be installed by adding ex_aws_code_deploy to your list of dependencies in mix.exs along with :ex_aws and your preferred JSON codec / http client. Example:

```elixir
def deps do
  [
    {:ex_aws, "~> 2.0"},
    {:ex_aws_code_deploy, "~> 2.0"},
    {:poison, "~> 3.0"},
    {:hackney, "~> 1.9"},
  ]
end
```

## Documentation

* [ex_aws](https://hexdocs.pm/ex_aws)
* [AWS CodeDeploy API](https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_ListApplications.html)
* [Go API for CodeDeploy](https://github.com/aws/aws-sdk-go/blob/master/models/apis/codedeploy/2014-10-06/api-2.json)

## License

[License](LICENSE)
