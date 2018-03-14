defmodule DeploymentInfo do
  alias __MODULE__

  defstruct [
    :application_name,
    :status,
    :deployment_config_name,
    :deployment_group_name,
    :deployment_id
  ]

  def new(response) do
    [
      {"applicationName", :application_name},
      {"status", :status},
      {"deploymentConfigName", :deployment_config_name},
      {"deploymentGroupName", :deployment_group_name},
      {"deploymentId", :deployment_id}
    ]
    |> Enum.reduce(%DeploymentInfo{}, fn {field_name, struct_key}, acc ->
      Map.put(acc, struct_key, get_in(response, [field_name]))
    end)
  end
end

defmodule AppInfo do
  alias __MODULE__

  defstruct [
    :app_id,
    :app_name,
    :compute_platform,
    :create_time,
    :linked_to_github
  ]

  def new(response) do
    create_time = Map.get(response, "createTime") |> Kernel.trunc() |> DateTime.from_unix()

    %AppInfo{
      app_id: Map.get(response, "applicationId"),
      app_name: Map.get(response, "applicationName"),
      compute_platform: Map.get(response, "computePlatform"),
      create_time: create_time
    }
  end
end

defmodule IExHelpers do
  @num_secs_in_day 86_400

  def list_deployments_since_yesterday(keys) do
    start =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * @num_secs_in_day)
      |> DateTime.from_naive!("Etc/UTC")
      |> DateTime.to_unix(:second)

    ExAws.CodeDeploy.list_deployments(create_time_range: %{"start" => start, "end" => nil})
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"deployments" => deployments}} -> deployments
      result -> result
    end
  end

  def list_applications(keys) do
    ExAws.CodeDeploy.list_applications()
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"applications" => apps}} -> apps
      result -> result
    end
  end

  def list_info_on_applications(keys) do
    list_applications(keys)
    |> Enum.chunk_every(100)
    |> Enum.map(fn app_names -> batch_get_applications(keys, app_names) end)
    |> List.flatten()
    |> Enum.map(fn app_info -> AppInfo.new(app_info) end)
  end

  def batch_get_applications(keys, app_names) do
    ExAws.CodeDeploy.batch_get_applications(app_names)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"applicationsInfo" => apps_info}} -> apps_info
      result -> result
    end
  end

  def list_all_deployment_groups(keys, throttle_ms) do
    list_applications(keys)
    |> Enum.map(fn app ->
      val = list_deployment_groups(keys, app)
      :timer.sleep(throttle_ms)
      val
    end)
  end

  def list_deployment_groups(keys, app) do
    ExAws.CodeDeploy.list_deployment_groups(app)
    |> ExAws.request(keys)
    |> case do
      {:ok, result} -> result
      result -> result
    end
  end

  def list_deployment_instances_since_yesterday(keys, throttle_ms) do
    list_deployments_since_yesterday(keys)
    |> Enum.map(fn deployment_id ->
      val = list_deployment_instances(keys, deployment_id)
      :timer.sleep(throttle_ms)
      %{deployment_id: deployment_id, instances: val}
    end)
  end

  def list_deployment_instances(keys, deployment_id) do
    ExAws.CodeDeploy.list_deployment_instances(deployment_id)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"instancesList" => instances}} -> instances
      result -> result
    end
  end

  def get_deployment(keys, deployment_id) do
    ExAws.CodeDeploy.get_deployment(deployment_id)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"deploymentInfo" => deployment_info}} -> deployment_info
      result -> result
    end
  end
end
