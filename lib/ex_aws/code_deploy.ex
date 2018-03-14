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
  """
  @spec batch_get_applications([binary, ...]) :: ExAws.Operation.JSON.t()
  def batch_get_applications(app_names) when is_list(app_names) do
    %{"applicationNames" => app_names}
    |> request(:batch_get_applications)
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
  @type deployment_options :: [
          application_name: binary,
          deployment_group_name: binary,
          include_only_statuses: [binary, ...],
          create_time_range: %{start: binary, end: binary},
          next_token: binary
        ]
  @spec list_deployments() :: ExAws.Operation.JSON.t()
  @spec list_deployments(opts :: deployment_options) :: ExAws.Operation.JSON.t()
  def list_deployments(opts \\ []) do
    opts |> camelize_keys(spec: @key_spec) |> request(:list_deployments)
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
