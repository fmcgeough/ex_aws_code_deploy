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
end
