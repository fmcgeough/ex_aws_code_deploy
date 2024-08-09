defmodule ExAws.CodeDeploy do
  @moduledoc """
  Operations on AWS CodeDeploy

  ## Description

  CodeDeploy is a deployment service that automates application deployments
  to Amazon EC2 instances, on-premises instances, serverless Lambda functions,
  or Amazon ECS services.

  You can deploy a nearly unlimited variety of application content, including:

  - Code
  - Serverless AWS Lambda functions
  - Web and configuration files
  - Executables
  - Packages
  - Scripts
  - Multimedia files

  ## Resources

  - [CodeDeploy User Guide](https://docs.aws.amazon.com/codedeploy/latest/userguide)
  - [CodeDeploy API Reference Guide](https://docs.aws.amazon.com/codedeploy/latest/APIReference/)
  - [CLI Reference for CodeDeploy](https://docs.aws.amazon.com/cli/latest/reference/deploy/index.html)
  - [CodeDeploy Developer Forum](https://forums.aws.amazon.com/forum.jspa?forumID=179)
  """

  alias ExAws.CodeDeploy.Utils
  alias ExAws.Operation.JSON, as: ExAwsOperationJSON

  # version of the AWS API
  @version "20141006"
  @namespace "CodeDeploy"

  @typedoc """
  Name of on-premise instance
  """
  @type instance_name() :: binary()

  @typedoc """
  Name of the application. Minimum length of 1. Maximum length of 100.
  """
  @type application_name() :: binary()

  @typedoc """
  The name of a deployment configuration associated with the user or AWS account. Minimum length of
  1. Maximum length of 100.
  """
  @type deployment_config_name() :: binary()

  @typedoc """
  Each deployment is assigned a unique id
  """
  @type deployment_id() :: binary()

  @typedoc """

  """
  @type instance_id() :: binary()

  @typedoc """
  Name of the deployment group. Minimum length of 1. Maximum length of 100.
  """
  @type deployment_group_name() :: binary()

  @typedoc """
  The name of the GitHub account connection
  """
  @type token_name() :: binary()

  @typedoc """
  The destination platform type for the deployment. Valid values
  are "Server", "Lambda" or "ECS"
  """
  @type compute_platform() :: binary()

  @type iam_session_arn() :: binary()

  @type iam_user_arn() :: binary()

  @typedoc """
  Input a user or session arn
  """
  @type input_session_or_user_arn ::
          %{optional(:iam_session_arn) => binary(), optional(:iam_user_arn) => binary()}
          | [{:iam_session_arn | :iam_user_arn, binary()}]

  @typedoc """
  Information about a tag.

  - key - the tag's key
  - value - the tag's value
  """
  @type tag :: {key :: atom() | binary(), value :: binary()}

  @typedoc """
  Some functions take only  an (optional) paging argument. Paging
  is done by passing in the "nextToken" returned by a previous call
  to the API endpoint. The value can be passed in as a keyword list,
  a Map, or a tuple.
  """
  @type paging_options :: [{:next_token, binary()}] | %{optional(:next_token) => binary()} | {:next_token, binary()}

  @typedoc """
  Information about the location of application artifacts stored in
  Amazon S3.

  - bucket - The name of the Amazon S3 bucket where the application
    revision is stored.
  - bundle_type - The file type of the application revision. Must be
    one of the following: "tar", "tgz", "zip", "YAML", "JSON".
  - e_tag - The ETag of the Amazon S3 object that represents the bundled
    artifacts for the application revision. If the ETag is not specified
    as an input parameter, ETag validation of the object is skipped.
  - key - The name of the Amazon S3 object that represents the bundled
    artifacts for the application revision.
  - version - A specific version of the Amazon S3 object that represents
    the bundled artifacts for the application revision. If the version is
    not specified, the system uses the most recent version by default.
  """
  @type s3_location() :: %{
          optional(:bucket) => binary(),
          optional(:bundle_type) => binary(),
          optional(:e_tag) => binary(),
          optional(:key) => binary(),
          optional(:version) => binary()
        }

  @typedoc """
  A revision for an AWS Lambda or Amazon ECS deployment that is a YAML-formatted
  or JSON-formatted string. For AWS Lambda and Amazon ECS deployments, the revision
  is the same as the AppSpec file. This method replaces the deprecated
  RawString data type.
  """
  @type app_spec_content() :: %{
          optional(:sha256) => binary(),
          optional(:content) => binary()
        }

  @typedoc """
  Information about the location of application artifacts stored in GitHub.

  - repository - The GitHub account and repository pair that stores a reference
    to the commit that represents the bundled artifacts for the application
    revision. Specified as account/repository.
  - commit_id - The SHA1 commit ID of the GitHub commit that represents the
    bundled artifacts for the application revision.
  """
  @type git_hub_location() :: %{
          optional(:repository) => binary(),
          optional(:commit_id) => binary()
        }

  @typedoc """
  Information about the location of an application revision
  """
  @type revision_location() :: %{
          optional(:revision_type) => binary(),
          optional(:s3_location) => s3_location(),
          optional(:git_hub_location) => git_hub_location(),
          optional(:app_spec_content) => app_spec_content()
        }

  @typedoc """
  Information about an EC2 tag filter.

  - key - The tag filter key
  - type - The tag filter type. Valid values: "KEY_ONLY",
    "VALUE_ONLY", "KEY_AND_VALUE"
  """
  @type ec2_tag_filter() :: %{
          optional(:key) => binary(),
          optional(:value) => binary(),
          optional(:type) => binary()
        }

  @typedoc """
  Information about groups of Amazon EC2 instance tags.
  """
  @type ec2_tag_set() :: %{
          optional(:ec2_tag_set_list) => [ec2_tag_filter()]
        }

  @typedoc """
  Information about the instances to be used in the replacement
  environment in a blue/green deployment.
  """
  @type target_instances() :: %{
          optional(:tag_filters) => [ec2_tag_filter()],
          optional(:auto_scaling_groups) => [binary()],
          optional(:ec2_tag_set) => ec2_tag_set()
        }

  @typedoc """
  Information about a configuration for automatically rolling back
  to a previous version of an application revision when a deployment
  is not completed successfully.

  - enabled - Indicates whether a defined automatic rollback
    configuration is currently enabled.
  - events - The event type or types that trigger a rollback. Valid
    values are: "DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM",
    "DEPLOYMENT_STOP_ON_REQUEST"
  """
  @type auto_rollback_configuration() :: %{
          optional(:enabled) => boolean(),
          optional(:events) => [binary()]
        }

  @typedoc """
  Information about an alarm.

  - name - The name of the alarm. Maximum length is 255 characters.
    Each alarm name can be used only once in a list of alarms.
  """
  @type alarm() :: %{
          optional(:name) => binary()
        }

  @typedoc """
  Information about alarms associated with a deployment or
  deployment group

  - alarms - A list of alarms configured for the deployment or
    deployment group. A maximum of 10 alarms can be added.
  - enabled - Indicates whether the alarm configuration is enabled.
  - ignore_poll_alarm_failure - Indicates whether a deployment should
    continue if information about the current state of alarms cannot
    be retrieved from Amazon CloudWatch. The default value is false.
  """
  @type alarm_configuration() :: %{
          optional(:alarms) => [alarm()],
          optional(:enabled) => boolean(),
          optional(:ignore_poll_alarm_failure) => boolean()
        }

  @typedoc """
  Optional input to the `create_deployment/2` function

  The required application name is passed in as the first argument
  separately from the map.
  """
  @type input_create_deployment() :: %{
          optional(:deployment_group_name) => binary(),
          optional(:revision) => revision_location(),
          optional(:deployment_config_name) => deployment_config_name(),
          optional(:description) => binary(),
          optional(:ignore_application_stop_failures) => boolean(),
          optional(:target_instances) => target_instances(),
          optional(:auto_rollback_configuration) => auto_rollback_configuration(),
          optional(:update_outdated_instances_only) => boolean(),
          optional(:file_exists_behavior) => binary(),
          optional(:override_alarm_configuration) => alarm_configuration()
        }

  @typedoc """
  Information about a time range.
  """
  @type time_range :: %{optional(:start) => binary(), optional(:end) => binary()}

  @typedoc """
  Optional input to the `list_deployments/1` function
  """
  @type input_list_deployments ::
          [
            application_name: application_name(),
            deployment_group_name: deployment_group_name(),
            include_only_statuses: [binary, ...],
            create_time_range: time_range(),
            next_token: binary
          ]
          | %{
              optional(:application_name) => application_name(),
              optional(:deployment_group_name) => deployment_group_name(),
              optional(:include_only_statuses) => [binary()],
              optional(:create_time_range) => time_range(),
              optional(:next_token) => binary()
            }

  @typedoc """
  Optional input to the `list_deployment_instances/2` function
  """
  @type input_list_deployment_instances ::
          [
            instance_status_filter: [binary, ...],
            instance_type_filter: [binary, ...],
            next_token: binary
          ]
          | %{
              optional(:instance_status_filter) => [binary()],
              optional(:instance_type_filter) => [binary()],
              optional(:next_token) => binary()
            }

  @doc """
  Lists the applications registered with the applicable IAM user or AWS account.

  ## Examples

      iex> ExAws.CodeDeploy.list_applications()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListApplications"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }

      iex> ExAws.CodeDeploy.list_applications([{:next_token, "AB1234Z6921"}])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"nextToken" => "AB1234Z6921"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListApplications"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_applications() :: ExAws.Operation.JSON.t()
  @spec list_applications(paging_options()) :: ExAws.Operation.JSON.t()
  def list_applications(opts \\ []) do
    opts |> Utils.build_paging() |> request(:list_applications)
  end

  @doc """
  Adds tags to on-premises instances.

  ## Examples

      iex> tags = [{"key1", "value"}, {"key2", "value"}]
      iex> instances = ["i-1234", "i-59922"]
      iex> ExAws.CodeDeploy.add_tags_to_on_premises_instances(instances, tags)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "instanceNames" => ["i-1234", "i-59922"],
          "tags" => [
            %{"Key" => "key1", "Value" => "value"},
            %{"Key" => "key2", "Value" => "value"}
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.AddTagsToOnPremisesInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec add_tags_to_on_premises_instances([instance_name()], [tag()]) :: ExAws.Operation.JSON.t()
  def add_tags_to_on_premises_instances(instance_names, tags) when is_list(instance_names) do
    api_tags = build_tags(tags)

    %{"instanceNames" => instance_names, "tags" => api_tags}
    |> request(:add_tags_to_on_premises_instances)
  end

  @doc """
  Gets information about one or more deployment groups.

  ## Examples

      iex> application_name = "TestApp-us-east-1"
      iex> deployment_group_names = ["dep-group-def-456", "dep-group-jkl-234"]
      iex> ExAws.CodeDeploy.batch_get_deployment_groups(application_name, deployment_group_names)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "TestApp-us-east-1",
          "deploymentGroupNames" => ["dep-group-def-456", "dep-group-jkl-234"]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetDeploymentGroups"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_deployment_groups(application_name(), [deployment_group_name()]) :: ExAws.Operation.JSON.t()
  def batch_get_deployment_groups(application_name, deployment_group_names) when is_list(deployment_group_names) do
    %{"applicationName" => application_name, "deploymentGroupNames" => deployment_group_names}
    |> request(:batch_get_deployment_groups)
  end

  @doc """
  Gets information about one or more applications. The maximum number of applications that can be
  returned is 100.

  ## Examples

      iex> ExAws.CodeDeploy.batch_get_applications(["TestDeploy1", "TestDeploy2"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationNames" => ["TestDeploy1", "TestDeploy2"]},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetApplications"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_applications([application_name()]) :: ExAws.Operation.JSON.t()
  def batch_get_applications(application_names) when is_list(application_names) do
    %{"applicationNames" => application_names}
    |> request(:batch_get_applications)
  end

  @doc """
  Gets information about one or more deployments. The maximum number of deployments that can be
  returned is 25.

  ## Examples

      iex> ExAws.CodeDeploy.batch_get_deployments(["d-A1B2C3111", "d-A1B2C3222"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentIds" => ["d-A1B2C3111", "d-A1B2C3222"]},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetDeployments"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_deployments([deployment_id()]) :: ExAws.Operation.JSON.t()
  def batch_get_deployments(deployment_ids) when is_list(deployment_ids) do
    %{"deploymentIds" => deployment_ids}
    |> request(:batch_get_deployments)
  end

  @doc """
  For a blue/green deployment, starts the process of rerouting traffic.

  Start the process of rerouting traffic from instances in the original
  environment to instances in the replacement environment without waiting
  for a specified wait time to elapse. (Traffic rerouting, which is achieved
  by registering instances in the replacement environment with the load
  balancer, can start as soon as all instances have a status of Ready.)
  """
  @spec continue_deployment(deployment_id()) :: ExAws.Operation.JSON.t()
  def continue_deployment(deployment_id) do
    %{"deploymentId" => deployment_id}
    |> request(:continue_deployment)
  end

  @doc """
  Creates an Application

  - application_name - Required. must be unique with the applicable IAM user or AWS account.
  - compute_platform - Optional. The destination platform type for the deployment. Valid values
    are "Server", "Lambda" or "ECS"
  - tags - Optional. The metadata that you apply to CodeDeploy applications to help you
    organize and categorize them. Each tag consists of a key and an optional value,
    both of which you define.

  ## Examples:

      iex> ExAws.CodeDeploy.create_application("TestDeploy")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "TestDeploy",
          "computePlatform" => "Server",
          "tags" => []
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }

      iex> tags = [{"key1", "value"}, {"key2", "value"}]
      iex> ExAws.CodeDeploy.create_application("TestDeploy", "Server", tags)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "TestDeploy",
          "computePlatform" => "Server",
          "tags" => [
            %{"Key" => "key1", "Value" => "value"},
            %{"Key" => "key2", "Value" => "value"}
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec create_application(application_name(), compute_platform(), [tag()]) :: ExAws.Operation.JSON.t()
  def create_application(application_name, compute_platform \\ "Server", tags \\ []) do
    %{"applicationName" => application_name, "computePlatform" => compute_platform, "tags" => build_tags(tags)}
    |> request(:create_application)
  end

  @doc """
  Deploys an application revision through the specified deployment group.

  Caller is responsible for defining the deployment_details in a manner that
  matches what Amazon expects. See unit test.
  """
  @spec create_deployment(application_name(), input_create_deployment()) :: ExAws.Operation.JSON.t()
  def create_deployment(application_name, deployment_details \\ %{}) do
    Map.merge(deployment_details, %{"applicationName" => application_name})
    |> request(:create_deployment)
  end

  @doc """
  Deletes an application.

  application_name: The name of an AWS CodeDeploy application associated with the applicable
  IAM user or AWS account.

  ## Examples

      iex> ExAws.CodeDeploy.delete_application("TestDeploy")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationName" => "TestDeploy"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeleteApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec delete_application(application_name()) :: ExAws.Operation.JSON.t()
  def delete_application(application_name) do
    %{"applicationName" => application_name}
    |> request(:delete_application)
  end

  @doc """
  Deletes a deployment configuration.

  A deployment configuration cannot be deleted if it is currently
  in use. Predefined configurations cannot be deleted.

  ## Examples

      iex> ExAws.CodeDeploy.delete_deployment_config("TestConfig")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentConfigName" => "TestConfig"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeleteDeploymentConfig"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec delete_deployment_config(deployment_config_name()) :: ExAws.Operation.JSON.t()
  def delete_deployment_config(deployment_config_name) do
    %{"deploymentConfigName" => deployment_config_name}
    |> request(:delete_deployment_config)
  end

  @doc """
  Deletes a deployment group.

  ## Examples

      iex> ExAws.CodeDeploy.delete_deployment_group("TestApp", "TestDeploy")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationName" => "TestApp", "deploymentGroupName" => "TestDeploy"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeleteDeploymentGroup"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec delete_deployment_group(application_name(), deployment_group_name()) :: ExAws.Operation.JSON.t()
  def delete_deployment_group(application_name, deployment_group_name) do
    %{"applicationName" => application_name, "deploymentGroupName" => deployment_group_name}
    |> request(:delete_deployment_group)
  end

  @doc """
  Deletes a GitHub account connection.

  ## Examples

      iex> ExAws.CodeDeploy.delete_git_hub_account_token("token")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"tokenName" => "token"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeleteGitHubAccountToken"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec delete_git_hub_account_token(token_name()) :: ExAws.Operation.JSON.t()
  def delete_git_hub_account_token(token_name) do
    %{"tokenName" => token_name}
    |> request(:delete_git_hub_account_token)
  end

  @doc """
  Deregisters an on-premises instance.

  ## Examples

      iex> ExAws.CodeDeploy.deregister_on_premises_instance("i-1234")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"instanceName" => "i-1234"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeregisterOnPremisesInstance"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec deregister_on_premises_instance(instance_name()) :: ExAws.Operation.JSON.t()
  def deregister_on_premises_instance(instance_name) do
    %{"instanceName" => instance_name}
    |> request(:deregister_on_premises_instance)
  end

  @doc """
  Gets information about one or more instance that are part of a deployment group.

  You can use `list_deployment_instances/1` to get a list of instances deployed to by a
  `t:deployment_id/0` but you need this function get details on the instances like startTime,
  endTime, lastUpdatedAt and instanceType.

  ## Examples

      iex> ExAws.CodeDeploy.batch_get_deployment_instances("TestDeploy", ["i-23324"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "TestDeploy", "instanceIds" => ["i-23324"]},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchSgetDeploymentInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  # @deprecated "Use batch_get_deployment_targets/2 instead"
  @spec batch_get_deployment_instances(deployment_id(), [instance_id()]) :: ExAws.Operation.JSON.t()
  def batch_get_deployment_instances(deployment_id, instance_ids) when is_list(instance_ids) do
    %{"deploymentId" => deployment_id, "instanceIds" => instance_ids}
    |> request(:batch_sget_deployment_instances)
  end

  @doc """
  Gets information about one or more on-premises instances.

  ## Examples

      iex> ExAws.CodeDeploy.batch_get_on_premises_instances(["i-23324", "i-43231"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"instanceNames" => ["i-23324", "i-43231"]},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetOnPremisesInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_on_premises_instances([instance_name()]) :: ExAws.Operation.JSON.t()
  def batch_get_on_premises_instances(instance_names) when is_list(instance_names) do
    %{"instanceNames" => instance_names}
    |> request(:batch_get_on_premises_instances)
  end

  @doc """
  Lists the deployment configurations with the applicable IAM user or AWS account.

  ## Examples

      iex> ExAws.CodeDeploy.list_deployment_configs()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListDeploymentConfigs"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_deployment_configs(paging_options()) :: ExAws.Operation.JSON.t()
  def list_deployment_configs(opts \\ []) do
    opts |> Utils.build_paging() |> request(:list_deployment_configs)
  end

  @doc """
  Lists the deployment groups for an application registered with the applicable IAM user or AWS account.

  This returns results that look like:

  ```
    {:ok,
      %{
        "applicationName" => "<your app name>",
        "deploymentGroups" => ["<your deploy group", ...]
      }}
  ```

  ## Examples

      iex> ExAws.CodeDeploy.list_deployment_groups("application")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationName" => "application"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListDeploymentGroups"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_deployment_groups(application_name(), paging_options()) :: ExAws.Operation.JSON.t()
  def list_deployment_groups(application_name, opts \\ []) do
    opts
    |> Utils.build_paging()
    |> Map.merge(%{"applicationName" => application_name})
    |> request(:list_deployment_groups)
  end

  @doc """
  Lists the deployments in a deployment group for an application registered with the applicable IAM user or AWS account.

  The start and end times are in Epoch time. To leave either open-ended pass in nil. Example:
  list_deployments(create_time_range: %{start: 1520963748, end: nil})

  ## Examples

      iex> ExAws.CodeDeploy.list_deployments()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListDeployments"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_deployments(input_list_deployments()) :: ExAws.Operation.JSON.t()
  def list_deployments(opts \\ []) do
    opts |> Utils.keyword_to_map() |> Utils.camelize_map() |> request(:list_deployments)
  end

  @doc """
  Gets information about an application.

  ## Examples

      iex> ExAws.CodeDeploy.get_application("TestApp")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationName" => "TestApp"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_application(application_name()) :: ExAws.Operation.JSON.t()
  def get_application(application_name) do
    %{"applicationName" => application_name}
    |> request(:get_application)
  end

  @doc """
  Gets information about an application revision.

  Caller is responsible for defining the revision details (if needed)
  in a manner that matches what Amazon expects. See unit test.

  ## Examples

      iex> ExAws.CodeDeploy.get_application_revision("TestApp")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"applicationName" => "TestApp"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetApplicationRevision"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_application_revision(application_name(), revision_location()) :: ExAws.Operation.JSON.t()
  def get_application_revision(application_name, revision \\ %{}) do
    Map.merge(revision, %{"applicationName" => application_name})
    |> request(:get_application_revision)
  end

  @doc """
  Gets information about a deployment.

  ## Examples:

      iex> ExAws.CodeDeploy.get_deployment("deploy_id")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "deploy_id"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_deployment(deployment_id()) :: ExAws.Operation.JSON.t()
  def get_deployment(deployment_id) do
    %{"deploymentId" => deployment_id}
    |> request(:get_deployment)
  end

  @doc """
  Gets information about a deployment configuration.
  """
  @spec get_deployment_config(deployment_config_name()) :: ExAws.Operation.JSON.t()
  def get_deployment_config(deployment_config_name) do
    %{"deploymentConfigName" => deployment_config_name}
    |> request(:get_deployment_config)
  end

  @doc """
  Gets information about a deployment group.

  ## Examples

      iex> ExAws.CodeDeploy.get_deployment_group("TestApp-us-east-1", "dep-group-def-456")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "TestApp-us-east-1",
          "deploymentGroupName" => "dep-group-def-456"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetDeploymentGroup"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_deployment_group(application_name(), deployment_group_name()) :: ExAws.Operation.JSON.t()
  def get_deployment_group(application_name, deployment_group_name) do
    %{"applicationName" => application_name, "deploymentGroupName" => deployment_group_name}
    |> request(:get_deployment_group)
  end

  @doc """
  Gets information about an instance as part of a deployment.

  ## Examples

      iex> ExAws.CodeDeploy.get_deployment_instance("d-7539MBT7C", "i-496636f700EXAMPLE")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "deploymentId" => "d-7539MBT7C",
          "instanceId" => "i-496636f700EXAMPLE"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetDeploymentInstance"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_deployment_instance(deployment_id(), instance_id()) :: ExAws.Operation.JSON.t()
  def get_deployment_instance(deployment_id, instance_id) do
    %{"deploymentId" => deployment_id, "instanceId" => instance_id}
    |> request(:get_deployment_instance)
  end

  @doc """
  Gets information about an on-premises instance
  """
  @spec get_on_premises_instance(instance_name()) :: ExAws.Operation.JSON.t()
  def get_on_premises_instance(instance_name) do
    %{"instanceName" => instance_name}
    |> request(:get_on_premises_instance)
  end

  @doc """
  Lists the instance for a deployment associated with the applicable IAM user or AWS account.

  ## Examples:

      iex> ExAws.CodeDeploy.list_deployment_instances("deploy_id")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "deploy_id"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListDeploymentInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_deployment_instances(deployment_id()) :: ExAws.Operation.JSON.t()
  @spec list_deployment_instances(deployment_id(), input_list_deployment_instances()) :: ExAws.Operation.JSON.t()
  def list_deployment_instances(deployment_id, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"deploymentId" => deployment_id})
    |> request(:list_deployment_instances)
  end

  @doc """
  Attempts to stop an ongoing deployment.

  ## Examples


      iex> ExAws.CodeDeploy.stop_deployment("i-123434")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "i-123434"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.StopDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec stop_deployment(deployment_id(), boolean() | nil) :: ExAws.Operation.JSON.t()
  def stop_deployment(deployment_id, auto_rollback_enabled \\ nil) do
    %{"deploymentId" => deployment_id}
    |> add_auto_rollback(auto_rollback_enabled)
    |> request(:stop_deployment)
  end

  @doc """
  Sets the result of a Lambda validation function. The function validates one or
  both lifecycle events (BeforeAllowTraffic and AfterAllowTraffic) and returns
  Succeeded or Failed.
  """
  @spec put_lifecycle_event_hook_execution_status(any(), any()) :: ExAws.Operation.JSON.t()
  def put_lifecycle_event_hook_execution_status(deployment_id, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"deploymentId" => deployment_id})
    |> request(:put_lifecycle_event_hook_execution_status)
  end

  @doc """
  Registers an on-premises instance.

  Only one IAM ARN (an IAM session ARN or IAM user ARN) is supported in the request. You cannot use
  both.

  ## Examples

      iex> arn_info = %{iam_session_arn: "3242342ABC"}
      iex> ExAws.CodeDeploy.register_on_premises_instance("i-12345", arn_info)
      ExAws.CodeDeploy.register_on_premises_instance("i-12345", %{iam_session_arn: "3242342ABC"})
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"iamSessionArn" => "3242342ABC", "instanceName" => "i-12345"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.RegisterOnPremisesInstance"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec register_on_premises_instance(instance_name(), input_session_or_user_arn()) ::
          ExAws.Operation.JSON.t()
  def register_on_premises_instance(instance_name, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"instanceName" => instance_name})
    |> request(:register_on_premises_instance)
  end

  @doc """
  Changes the name of an application.
  """
  @spec update_application(application_name(), application_name()) :: ExAws.Operation.JSON.t()
  def(update_application(application_name, new_application_name)) do
    %{"applicationName" => application_name, "newApplicationName" => new_application_name}
    |> request(:update_application)
  end

  ####################
  # Helper Functions #
  ####################
  defp add_auto_rollback(acc, auto_rollback) when is_boolean(auto_rollback) do
    Map.put(acc, "autoRollbackEnabled", auto_rollback)
  end

  defp add_auto_rollback(acc, _), do: acc

  defp build_tags(tags) when is_list(tags) do
    Enum.map(tags, fn {k, v} -> %{"Key" => k, "Value" => v} end)
  end

  defp build_tags(_tags), do: []

  defp request(data, action, opts \\ %{}) do
    operation = Utils.camelize(action, :upper)

    ExAwsOperationJSON.new(
      :codedeploy,
      %{
        data: data,
        headers: [
          {"x-amz-target", "#{@namespace}_#{@version}.#{operation}"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
      }
      |> Map.merge(opts)
    )
  end
end
