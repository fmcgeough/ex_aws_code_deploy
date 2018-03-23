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
    create_time = Map.get(response, "createTime") |> Kernel.trunc() |> DateTime.from_unix!()

    %AppInfo{
      app_id: Map.get(response, "applicationId"),
      app_name: Map.get(response, "applicationName"),
      compute_platform: Map.get(response, "computePlatform"),
      create_time: create_time
    }
  end
end

defmodule IExHelpers do
  @begin_of_day "T00:00:00.0Z"
  @end_of_day "T23:59:59.0Z"

  @doc """
    List all deployments for a date
  """
  def list_deployments_yesterday(keys) do
    list_deployments_for_date(keys, yesterday())
  end

  def list_deployments_for_date(keys, dt) do
    dt
    |> day_range()
    |> case do
      {:ok, dt1, dt2} -> list_deployments_for_date(keys, dt1, dt2)
      {:error, _, _} -> []
    end
  end

  def list_applications(keys) do
    apps = inner_list_applications(keys)
    list_more_applications(keys, apps["applications"], apps["nextToken"])
  end

  def list_info_on_applications(keys) do
    list_applications(keys)
    |> Enum.chunk_every(100)
    |> Enum.map(fn app_names -> batch_get_applications(keys, app_names) end)
    |> List.flatten()
    |> Enum.map(fn app_info -> AppInfo.new(app_info) end)
  end

  @doc """
    List all Deployment Groups for an app.

    Returned value from API.
    {
    "applicationName": "string",
    "deploymentGroups": [ "string" ],
    "nextToken": "string"
    }
  """
  def list_deployment_groups(keys, app) do
    deploy_groups = inner_list_deployment_groups(keys, app)

    list_more_deployment_groups(
      keys,
      app,
      deploy_groups["deploymentGroups"],
      deploy_groups["nextToken"]
    )
  end

  def batch_get_deployments(keys, deployment_ids) do
    ExAws.CodeDeploy.batch_get_deployments(deployment_ids)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"deploymentsInfo" => deployments_info}} -> deployments_info
      result -> result
    end
  end

  def list_deployment_instances_since_yesterday(keys, throttle_ms) do
    list_deployments_yesterday(keys)
    |> Enum.map(fn deployment_id ->
      val = list_deployment_instances(keys, deployment_id)
      :timer.sleep(throttle_ms)
      %{deployment_id: deployment_id, instances: val}
    end)
  end

  def list_deployment_instances(keys, deployment_id) do
    instances = inner_list_deployment_instances(keys, deployment_id)

    list_more_deployment_instances(
      keys,
      deployment_id,
      instances["instancesList"],
      instances["nextToken"]
    )
  end

  def get_deployment(keys, deployment_id) do
    ExAws.CodeDeploy.get_deployment(deployment_id)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"deploymentInfo" => deployment_info}} -> deployment_info
      result -> result
    end
  end

  defp inner_list_deployment_instances(keys, deployment_id) do
    ExAws.CodeDeploy.list_deployment_instances(deployment_id)
    |> ExAws.request(keys)
    |> case do
      {:ok, instances} -> instances
      _ -> %{"instancesList" => []}
    end
  end

  defp list_more_deployment_instances(_keys, _deployment_id, acc, nil), do: acc

  defp list_more_deployment_instances(keys, deployment_id, acc, next_token) do
    instances = inner_list_more_deployment_instances(keys, deployment_id, next_token)

    list_more_deployment_instances(
      keys,
      deployment_id,
      Enum.concat(acc, instances["instancesList"]),
      instances["nextToken"]
    )
  end

  def inner_list_more_deployment_instances(keys, deployment_id, next_token) do
    ExAws.CodeDeploy.list_deployment_instances(deployment_id, next_token: next_token)
    |> ExAws.request(keys)
    |> case do
      {:ok, instances} -> instances
      _ -> %{"instancesList" => []}
    end
  end

  defp batch_get_applications(keys, app_names) do
    ExAws.CodeDeploy.batch_get_applications(app_names)
    |> ExAws.request(keys)
    |> case do
      {:ok, %{"applicationsInfo" => apps_info}} -> apps_info
      _ -> []
    end
  end

  defp yesterday do
    Date.utc_today() |> Date.add(-1)
  end

  defp iso8601_to_datetime(str) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> dt
      _ -> :error
    end
  end

  defp day_range(dt) do
    str = dt |> Date.to_iso8601()
    begin_day = str <> @begin_of_day
    end_day = str <> @end_of_day

    case {iso8601_to_datetime(begin_day), iso8601_to_datetime(end_day)} do
      {:error, _} -> {:error, nil, nil}
      {_, :error} -> {:error, nil, nil}
      {dt1, dt2} -> {:ok, DateTime.to_unix(dt1, :second), DateTime.to_unix(dt2, :second)}
    end
  end

  defp inner_list_deployment_groups(keys, app) do
    ExAws.CodeDeploy.list_deployment_groups(app)
    |> ExAws.request(keys)
    |> case do
      {:ok, result} -> result
      _ -> %{"deploymentGroups" => []}
    end
  end

  defp inner_list_more_deployment_groups(keys, app, next_token) do
    ExAws.CodeDeploy.list_deployment_groups(app, next_token: next_token)
    |> ExAws.request(keys)
    |> case do
      {:ok, result} -> result
      _ -> %{"deploymentGroups" => []}
    end
  end

  defp list_more_deployment_groups(_keys, _app, acc, nil), do: acc

  defp list_more_deployment_groups(keys, app, acc, next_token) do
    deployment_groups = inner_list_more_deployment_groups(keys, app, next_token)

    list_more_deployment_groups(
      keys,
      app,
      Enum.concat(acc, deployment_groups["deploymentGroups"]),
      deployment_groups["nextToken"]
    )
  end

  def list_deployments_for_date(keys, start_sec, end_sec) do
    deployments = inner_list_deployments_for_date(keys, start_sec, end_sec)
    list_more_deployments(keys, deployments["deployments"], deployments["nextToken"])
  end

  def list_more_deployments(_keys, acc, nil), do: acc

  def list_more_deployments(keys, acc, next_token) do
    deployments = inner_list_more_deployments(keys, next_token)

    list_more_deployments(
      keys,
      Enum.concat(acc, deployments["deployments"]),
      deployments["nextToken"]
    )
  end

  def inner_list_deployments_for_date(keys, start_sec, end_sec) do
    ExAws.CodeDeploy.list_deployments(
      create_time_range: %{"start" => start_sec, "end" => end_sec}
    )
    |> ExAws.request(keys)
    |> case do
      {:ok, deployments} -> deployments
      _ -> %{"deployments" => []}
    end
  end

  def inner_list_more_deployments(keys, next_token) do
    ExAws.CodeDeploy.list_deployments(next_token: next_token)
    |> ExAws.request(keys)
    |> case do
      {:ok, deployments} -> deployments
      _ -> %{"deployments" => []}
    end
  end

  def list_more_applications(_keys, acc, nil), do: acc

  def list_more_applications(keys, acc, next_token) do
    apps = inner_list_applications(keys, next_token)

    list_more_applications(
      keys,
      Enum.concat(acc, apps["applications"]),
      apps["nextToken"]
    )
  end

  def inner_list_applications(keys) do
    ExAws.CodeDeploy.list_applications()
    |> ExAws.request(keys)
    |> case do
      {:ok, apps} ->
        apps

      _ ->
        %{"applications" => []}
    end
  end

  def inner_list_applications(keys, next_token) do
    ExAws.CodeDeploy.list_applications(next_token: next_token)
    |> ExAws.request(keys)
    |> case do
      {:ok, apps} ->
        apps

      _ ->
        %{"applications" => []}
    end
  end
end
