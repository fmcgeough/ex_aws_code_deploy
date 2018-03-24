defmodule ExAws.CodeDeploy do
  @moduledoc """
    Operations on AWS Code Deploy
  """
  # version of the AWS API

  import ExAws.Utils, only: [camelize_keys: 1, camelize_keys: 2]

  @version "20141006"
  @namespace "CodeDeploy"
  @key_spec %{
    application_name: "applicationName",
    deployment_group_name: "deploymentGroupName",
    include_only_statues: "includeOnlyStatues",
    create_time_range: "createTimeRange",
    next_token: "nextToken",
    instance_status_filter: "instanceStatusFilter",
    instance_type_filter: "instanceTypeFilter"
  }

  @doc """
    Lists the applications registered with the applicable IAM user or AWS account.

  ## Examples:

        iex> ExAws.CodeDeploy.list_applications().headers
        [
            {"x-amz-target", "CodeDeploy_20141006.ListApplications"},
            {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @type paging_options :: [
          {:next_token, binary}
        ]
  @spec list_applications() :: ExAws.Operation.JSON.t()
  @spec list_applications(opts :: paging_options) :: ExAws.Operation.JSON.t()
  def list_applications(opts \\ []) do
    opts |> camelize_keys() |> request(:list_applications)
  end

  @doc """
    Gets information about one or more applications.

        iex> ExAws.CodeDeploy.batch_get_applications(["TestDeploy1", "TestDeploy2"]).headers
        [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetApplications"},
          {"content-type", "application/x-amz-json-1.1"}
        ]

        iex> ExAws.CodeDeploy.batch_get_applications(["TestDeploy1", "TestDeploy2"]).data
        %{"applicationNames" => ["TestDeploy1", "TestDeploy2"]}
  """
  @spec batch_get_applications([binary, ...]) :: ExAws.Operation.JSON.t()
  def batch_get_applications(app_names) when is_list(app_names) do
    %{"applicationNames" => app_names}
    |> request(:batch_get_applications)
  end

  @doc """
    Gets information about one or more deployments.
  """
  @spec batch_get_deployments([binary, ...]) :: ExAws.Operation.JSON.t()
  def batch_get_deployments(deployment_ids) when is_list(deployment_ids) do
    %{"deploymentIds" => deployment_ids}
    |> request(:batch_get_deployments)
  end

  @doc """
    Creates an Application

    application_name must be unique with the applicable IAM user or AWS account.
    compute_platform Lambda or Server.

        iex> ExAws.CodeDeploy.create_application("TestDeploy").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.CreateApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ]

        iex> ExAws.CodeDeploy.create_application("TestDeploy").data
        %{"applicationName" => "TestDeploy", "computePlatform" => "Server"}
  """
  @spec create_application(binary) :: ExAws.Operation.JSON.t()
  @spec create_application(binary, binary) :: ExAws.Operation.JSON.t()
  def create_application(application_name, compute_platform \\ "Server") do
    %{"applicationName" => application_name, "computePlatform" => compute_platform}
    |> request(:create_application)
  end

  @doc """
    Deletes an application.

    application_name: The name of an AWS CodeDeploy application associated with the applicable
    IAM user or AWS account.

        iex> ExAws.CodeDeploy.delete_application("TestDeploy").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.DeleteApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_application(binary) :: ExAws.Operation.JSON.t()
  def delete_application(application_name) do
    %{"applicationName" => application_name}
    |> request(:delete_application)
  end

  @doc """
    Deletes a deployment configuration.

    A deployment configuration cannot be deleted if it is currently
    in use. Predefined configurations cannot be deleted.

        iex> ExAws.CodeDeploy.delete_deployment_config("TestConfig").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.DeleteDeploymentConfig"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_deployment_config(binary) :: ExAws.Operation.JSON.t()
  def delete_deployment_config(deployment_config_name) do
    %{"deploymentConfigName" => deployment_config_name}
    |> request(:delete_deployment_config)
  end

  @doc """
    Deletes a deployment group.

        iex> ExAws.CodeDeploy.delete_deployment_group("TestApp", "TestDeploy").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.DeleteDeploymentGroup"},
          {"content-type", "application/x-amz-json-1.1"}
        ]

        iex> ExAws.CodeDeploy.delete_deployment_group("TestApp", "TestDeploy").data
        %{"applicationName" => "TestApp", "deploymentGroupName" => "TestDeploy"}
  """
  @spec delete_deployment_group(binary, binary) :: ExAws.Operation.JSON.t()
  def delete_deployment_group(application_name, deployment_group_name) do
    %{"applicationName" => application_name, "deploymentGroupName" => deployment_group_name}
    |> request(:delete_deployment_group)
  end

  @doc """
    Deletes a GitHub account connection.

        iex> ExAws.CodeDeploy.delete_git_hub_account_token("token").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.DeleteGitHubAccountToken"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec delete_git_hub_account_token(binary) :: ExAws.Operation.JSON.t()
  def delete_git_hub_account_token(token_name) do
    %{"tokenName" => token_name}
    |> request(:delete_git_hub_account_token)
  end

  @doc """
    Deregisters an on-premises instance.

        iex> ExAws.CodeDeploy.deregister_on_premises_instance("i-1234").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.DeregisterOnPremisesInstance"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  def deregister_on_premises_instance(instance_name) do
    %{"instanceName" => instance_name}
    |> request(:deregister_on_premises_instance)
  end

  @doc """
    Gets information about one or more instance that are part of a deployment group.

    You can use `list_deployment_instances/1` to get a list of instances
    deployed to by a deployment_id but you need this function get details on
    the instances like startTime, endTime, lastUpdatedAt and instanceType.

        iex> ExAws.CodeDeploy.batch_get_deployment_instances("TestDeploy", ["i-23324"]).headers
        [
          {"x-amz-target", "CodeDeploy_20141006.BatchSgetDeploymentInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ]

        iex> ExAws.CodeDeploy.batch_get_deployment_instances("TestDeploy", ["i-23324"]).data
        %{"deploymentId" => "TestDeploy", "instanceIds" => ["i-23324"]}
  """
  def batch_get_deployment_instances(deployment_id, instance_ids) when is_list(instance_ids) do
    %{"deploymentId" => deployment_id, "instanceIds" => instance_ids}
    |> request(:batch_sget_deployment_instances)
  end

  @doc """
    Lists the deployment configurations with the applicable IAM user or AWS account.

  ## Examples:

        iex> ExAws.CodeDeploy.list_deployment_configs().headers
        [
            {"x-amz-target", "CodeDeploy_20141006.ListDeploymentConfigs"},
            {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec list_deployment_configs() :: ExAws.Operation.JSON.t()
  @spec list_deployment_configs(opts :: paging_options) :: ExAws.Operation.JSON.t()
  def list_deployment_configs(opts \\ []) do
    opts |> camelize_keys() |> request(:list_deployment_configs)
  end

  @doc """
    Lists the deployment groups for an application registered with the applicable IAM user or AWS account.

    This returns results that look like:

    {:ok,
      %{
        "applicationName" => "<your app name>",
        "deploymentGroups" => ["<your deploy group", ...]
      }}

  ## Examples:

        iex> ExAws.CodeDeploy.list_deployment_groups("application").data
        %{"applicationName" => "application"}
  """
  @spec list_deployment_groups(application_name :: binary) :: ExAws.Operation.JSON.t()
  @spec list_deployment_groups(application_name :: binary, opts :: paging_options) ::
          ExAws.Operation.JSON.t()
  def list_deployment_groups(application_name, opts \\ []) do
    opts |> camelize_keys() |> Map.merge(%{"applicationName" => application_name})
    |> request(:list_deployment_groups)
  end

  @doc """
    Lists the deployments in a deployment group for an application registered with the applicable IAM user or AWS account.

    The start and end times are in Epoch time. To leave either open-ended pass in nil. Example:
    list_deployments(create_time_range: %{start: 1520963748, end: nil})

  ## Examples:

        iex> ExAws.CodeDeploy.list_deployments().headers
        [
          {"x-amz-target", "CodeDeploy_20141006.ListDeployments"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @type time_range :: %{optional(binary) => binary}
  @type list_deployments_options :: [
          application_name: binary,
          deployment_group_name: binary,
          include_only_statuses: [binary, ...],
          create_time_range: map(),
          next_token: binary
        ]
  @spec list_deployments() :: ExAws.Operation.JSON.t()
  @spec list_deployments(opts :: list_deployments_options) :: ExAws.Operation.JSON.t()
  def list_deployments(opts \\ []) do
    opts |> camelize_keys(spec: @key_spec) |> request(:list_deployments)
  end

  @doc """
    Gets information about an application.

        iex> ExAws.CodeDeploy.get_application("TestApp").headers
        [
          {"x-amz-target", "CodeDeploy_20141006.GetApplication"},
          {"content-type", "application/x-amz-json-1.1"}
        ]
  """
  @spec get_application(application_name :: binary) :: ExAws.Operation.JSON.t()
  def get_application(application_name) do
    %{"applicationName" => application_name}
    |> request(:get_application)
  end

  @doc """
    Gets information about a deployment.

  ## Examples:

        iex> ExAws.CodeDeploy.get_deployment("deploy_id").data
        %{"deploymentId" => "deploy_id"}
  """
  @spec get_deployment(deployment_id :: binary) :: ExAws.Operation.JSON.t()
  def get_deployment(deployment_id) do
    %{"deploymentId" => deployment_id}
    |> request(:get_deployment)
  end

  @doc """
    Gets information about a deployment configuration.
  """
  @spec get_deployment_config(deployment_config_name :: binary) :: ExAws.Operation.JSON.t()
  def get_deployment_config(deployment_config_name) do
    %{"deploymentConfigName" => deployment_config_name}
    |> request(:get_deployment_config)
  end

  @doc """
    Gets information about a deployment group.
  """
  @spec get_deployment_group(application_name :: binary, deployment_group_name :: binary) ::
          ExAws.Operation.JSON.t()
  def get_deployment_group(application_name, deployment_group_name) do
    %{"applicationName" => application_name, "deploymentGroupName" => deployment_group_name}
    |> request(:get_deployment_group)
  end

  @doc """
    Gets information about an instance as part of a deployment.
  """
  @spec get_deployment_instance(deployment_id :: binary, instance_id :: binary) ::
          ExAws.Operation.JSON.t()
  def get_deployment_instance(deployment_id, instance_id) do
    %{"deploymentId" => deployment_id, "instanceId" => instance_id}
    |> request(:get_deployment_instance)
  end

  @doc """
    Gets information about an on-premises instance
  """
  @spec get_on_premises_instance(instance_name :: binary) :: ExAws.Operation.JSON.t()
  def get_on_premises_instance(instance_name) do
    %{"instanceName" => instance_name}
    |> request(:get_on_premises_instance)
  end

  @doc """
    Lists the instance for a deployment associated with the applicable IAM user or AWS account.

  ## Examples:

        iex> ExAws.CodeDeploy.list_deployment_instances("deploy_id").data
        %{"deploymentId" => "deploy_id"}
  """
  @type list_deployment_instances_opts :: [
          instance_status_filter: [binary, ...],
          instance_type_filter: [binary, ...],
          next_token: binary
        ]
  @spec list_deployment_instances(deployment_id :: binary) :: ExAws.Operation.JSON.t()
  @spec list_deployment_instances(deployment_id :: binary, opts :: list_deployment_instances_opts) ::
          ExAws.Operation.JSON.t()
  def list_deployment_instances(deployment_id, opts \\ []) do
    opts |> camelize_keys(spec: @key_spec) |> Map.merge(%{"deploymentId" => deployment_id})
    |> request(:list_deployment_instances)
  end

  ####################
  # Helper Functions #
  ####################

  defp request(data, action, opts \\ %{}) do
    operation = action |> Atom.to_string() |> Macro.camelize()

    ExAws.Operation.JSON.new(
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
