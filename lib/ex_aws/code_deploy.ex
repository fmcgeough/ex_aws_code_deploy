defmodule ExAws.CodeDeploy do
  @moduledoc """
    Operations on AWS Code Deploy
  """
  # version of the AWS API

  use ExAws.Utils,
    format_type: :xml,
    non_standard_keys: %{}

  @version "20141006"
  @namespace "CodeDeploy"

  @doc """
    Lists the applications registered with the applicable IAM user or AWS account.

  ## Examples:

        iex> ExAws.CodeDeploy.list_applications()
        %ExAws.Operation.JSON{
          before_request: nil,
          data: %{},
          headers: [
            {"x-amz-target", "CodeDeploy_20141006.ListApplications"},
            {"content-type", "application/x-amz-json-1.1"}
          ],
          http_method: :post,
          params: %{},
          parser: nil,
          path: "/",
          service: :codedeploy,
          stream_builder: nil
          }
  """
  @type list_applications_opts :: [
          next_token: binary
        ]
  @spec list_applications() :: ExAws.Operation.JSON.t()
  @spec list_applications(opts :: list_applications_opts) :: ExAws.Operation.JSON.t()
  def list_applications(opts \\ []) do
    opts |> build_request(:list_applications)
  end

  ####################
  # Helper Functions #
  ####################

  defp build_request(opts, action) do
    opts
    |> Enum.flat_map(&format_param/1)
    |> request(action)
  end

  defp request(params, action) do
    action_string = action |> Atom.to_string() |> Macro.camelize()

    %ExAws.Operation.JSON{
      http_method: :post,
      headers: [
        {"x-amz-target", "#{@namespace}_#{@version}.#{action_string}"},
        {"content-type", "application/x-amz-json-1.1"}
      ],
      data:
        params
        |> filter_nil_params,
      service: :codedeploy
      # parser: &ExAws.Support.Parsers.parse/2
    }
  end

  defp format_param({key, parameters}) do
    format([{key, parameters}])
  end
end
