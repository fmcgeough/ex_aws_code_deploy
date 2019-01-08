defmodule ExAwsCodeDeployTest do
  use ExUnit.Case
  doctest ExAws.CodeDeploy
  alias ExAws.CodeDeploy

  test "get application revision from S3" do
    revision = %{
      "revision" => %{
        "revisionType" => "S3",
        "s3Location" => %{
          "bundleType" => "zip",
          "eTag" => "fff9102ckv48b652bf903700453f7408",
          "bucket" => "project-1234",
          "key" => "North-App.zip"
        }
      }
    }

    op = CodeDeploy.get_application_revision("Test", revision)

    assert op.data == %{
             "applicationName" => "Test",
             "revision" => %{
               "revisionType" => "S3",
               "s3Location" => %{
                 "bucket" => "project-1234",
                 "bundleType" => "zip",
                 "eTag" => "fff9102ckv48b652bf903700453f7408",
                 "key" => "North-App.zip"
               }
             }
           }
  end

  test "create deployment with caller defined deployment details" do
    deployment_details = %{
      "autoRollbackConfiguration" => %{
        "enabled" => true,
        "events" => [
          "DEPLOYMENT_FAILURE"
        ]
      },
      "deploymentGroupName" => "dep-group-ghi-789",
      "description" => "Deployment for Project 1234",
      "deploymentConfigName" => "CodeDeployDefault.OneAtATime",
      "ignoreApplicationStopFailures" => true,
      "revision" => %{
        "revisionType" => "S3",
        "s3Location" => %{
          "bundleType" => "zip",
          "bucket" => "project-1234",
          "key" => "East-App.zip"
        },
        "updateOutdatedInstancesOnly" => true
      }
    }

    op = CodeDeploy.create_deployment("Test", deployment_details)
    assert op.data == Map.merge(deployment_details, %{"applicationName" => "Test"})
  end
end
