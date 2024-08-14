defmodule ExAws.CodeDeploy do
  @moduledoc """
  Operations on AWS CodeDeploy

  The documentation and types provided lean heavily on the [AWS documentation for
  CodeDeploy](https://docs.aws.amazon.com/codedeploy/index.html). The AWS documentation is the
  definitive source of information and should be consulted to understand how to use CodeDeploy and
  its API functions.

  Generally the functions that wrap the API take required parameters as separate unique arguments
  and any optional arguments are passed as a Map (with a defined type).

  For the API's that take a structure the types are defined using the standard Elixir snake-case.
  The API itself uses camel-case. For camel-case most API keys use a lower-case letter for the first
  word and upper-case for the subsequent words. However, there are exceptions to this rule. The
  exceptions are handled by the library so an Elixir developer can just use standard snake-case for
  all the keys.

  ## Description

  CodeDeploy is a deployment service that automates application deployments to Amazon EC2 instances,
  on-premises instances, serverless Lambda functions, or Amazon ECS services.

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
  @valid_deployment_wait_types ["READY_WAIT", "TERMINATION_WAIT"]

  @typedoc """
  Name of on-premise instance
  """
  @type instance_name() :: binary()

  @typedoc """
  Name of the application. Minimum length of 1. Maximum length of 100.
  """
  @type application_name() :: binary()

  @typedoc """
  The name of a deployment configuration associated with the user or AWS account. Minimum length
  allowed is 1. Maximum length is 100.
  """
  @type deployment_config_name() :: binary()

  @typedoc """
  Each deployment is assigned a unique id
  """
  @type deployment_id() :: binary()

  @typedoc """
  The status of the deployment's waiting period. "READY_WAIT" indicates that the deployment is ready
  to start shifting traffic. "TERMINATION_WAIT" indicates that the traffic is shifted, but the
  original target is not terminated.

  Valid values:
  ```
  ["READY_WAIT", "TERMINATION_WAIT"]
  ```
  """
  @type deployment_wait_type() :: binary()

  @typedoc """
  instance ID is the 36-character string at the end of your instance's Amazon Resource Name (ARN)
  """
  @type instance_id() :: binary()

  @typedoc """
  The ARN of a CodeDeploy resource

  Length Constraints: Minimum length of 1. Maximum length of 1011.
  """
  @type resource_arn() :: binary()

  @typedoc """
  The unique IDs of the deployment targets. The compute platform of the deployment determines the
  type of the targets and their formats.

  - For deployments that use the EC2/On-premises compute platform, the target IDs are Amazon EC2 or
    on-premises instances IDs, and their target type is "instanceTarget".
  - For deployments that use the AWS Lambda compute platform, the target IDs are the names of Lambda
    functions, and their target type is "instanceTarget".
  - For deployments that use the Amazon ECS compute platform, the target IDs are pairs of Amazon ECS
    clusters and services specified using the format <clustername>:<servicename>. Their target type
    is "ecsTarget".
  - For deployments that are deployed with AWS CloudFormation, the target IDs are CloudFormation
    stack IDs. Their target type is "cloudFormationTarget".
  """
  @type target_id() :: binary()

  @typedoc """
  A list of `t:target_id/0`
  """
  @type target_ids() :: [target_id()]

  @typedoc """
  Name of the deployment group. Minimum length of 1. Maximum length of 100.
  """
  @type deployment_group_name() :: binary()

  @typedoc """
  The name of the GitHub account connection
  """
  @type token_name() :: binary()

  @typedoc """
  The destination platform type for the deployment.

  Valid values
  ```
  ["Server", "Lambda", "ECS"]
  ```
  """
  @type compute_platform() :: binary()

  @typedoc """
  AWS Identity and Access Management (IAM) Session Amazon Resource Name (ARN)
  """
  @type iam_session_arn() :: binary()

  @typedoc """
  AWS Identity and Access Management (IAM) User Amazon Resource Name (ARN)
  """
  @type iam_user_arn() :: binary()

  @typedoc """
  A service role Amazon Resource Name (ARN) that allows AWS CodeDeploy to act on the user's behalf
  when interacting with AWS services.
  """
  @type service_role_arn() :: binary()

  @typedoc """
  Input a user or session arn
  """
  @type register_on_premises_instance_optional_details() ::
          %{optional(:iam_session_arn) => binary(), optional(:iam_user_arn) => binary()}
          | [{:iam_session_arn | :iam_user_arn, binary()}]

  @typedoc """
  Information about a tag.

  - key - the value contains the tag's key
  - value - the value contains the tag's value
  """
  @type tag :: %{
          optional(:key) => binary(),
          optional(:value) => binary()
        }

  @typedoc """
  In order to provide backward compatability the type `t:primitive_tag/0` is available. With this
  type a tag consists of a 2-element tuple where the key is the first element and the value is the
  second. The new `t:tag/0` type provides greater flexibilty and is preferred. This type can only be
  passed for the functions `create_application/3` and `add_tags_to_on_premises_instances/2`.

  ## Example

  ```
  primitive_tag = {"my_key", "my_value"}
  ```
  """
  @type primitive_tag :: {binary(), binary()}

  @typedoc """
  A list of tags
  """
  @type tags() :: [tag()]

  @typedoc """
  Specifies the tag filter type

  Valid Values
  ```
  ["KEY_ONLY", "VALUE_ONLY", "KEY_AND_VALUE"]
  ```
  """
  @type tag_filter_type() :: binary()

  @typedoc """
  Information about an on-premises instance tag filter.

  - key - The on-premises instance tag filter key
  - value - The on-premises instance tag filter value
  - type - The on-premises instance tag filter type
  """
  @type tag_filter() :: %{
          optional(:key) => binary(),
          optional(:value) => binary(),
          optional(:type) => tag_filter_type()
        }

  @typedoc """
  List of `t:tag_filter/0`
  """
  @type tag_filter_list() :: [tag_filter()]

  @typedoc """
  Information about groups of on-premises instance tags.

  on_premises_tag_set_list - A list that contains other lists of on-premises instance tag groups.
  For an instance to be included in the deployment group, it must be identified by all of the tag
  groups in the list
  """
  @type on_premises_tag_set() :: %{
          optional(:on_premises_tag_set_list) => [tag_filter()]
        }

  @typedoc """
  Information about an Auto Scaling group

  - hook - The name of the launch hook that CodeDeploy installed into the Auto Scaling group
  - name - The Auto Scaling group name
  - termination_hook -The name of the termination hook that CodeDeploy installed into the Auto
    Scaling group
  """
  @type auto_scaling_group() :: %{
          optional(:hook) => binary(),
          optional(:name) => binary(),
          optional(:termination_hook) => binary()
        }

  @typedoc """
  A trigger event

  Valid Values:
  ```
  ["DeploymentStart", "DeploymentSuccess", "DeploymentFailure", "DeploymentStop",
  "DeploymentRollback", "DeploymentReady", "InstanceStart", "InstanceSuccess",
  "InstanceFailure", "InstanceReady"]
  ```
  """
  @type trigger_event() :: binary()

  @typedoc """
  Indicates what happens when new Amazon EC2 instances are launched mid-deployment and do not
  receive the deployed application revision.

  If this option is set to "UPDATE" or is unspecified, CodeDeploy initiates one or more 'auto-update
  outdated instances' deployments to apply the deployed application revision to the new Amazon EC2
  instances.

  If this option is set to "IGNORE", CodeDeploy does not initiate a deployment to update the new
  Amazon EC2 instances. This may result in instances having different revisions.

  Valid values
  ```
  ["IGNORE", "UPDATE"]
  ```
  """
  @type outdated_instances_strategy() :: binary()

  @typedoc """
  Indicates whether to route deployment traffic behind a load balancer.

  Valid Values:
  ```
  ["WITH_TRAFFIC_CONTROL", "WITHOUT_TRAFFIC_CONTROL"]
  ```
  """
  @type deployment_option() :: binary()

  @typedoc """
  Indicates whether to run an in-place deployment or a blue/green deployment.

  Value values
  ```
  ["IN_PLACE", "BLUE_GREEN"]
  ```
  """
  @type deployment_type() :: binary()

  @typedoc """
  Information about the type of deployment, either in-place or blue/green, you want to run and
  whether to route deployment traffic behind a load balancer.

  - deployment_option - Indicates whether to route deployment traffic behind a load balancer.
  - deployment_type - Indicates whether to run an in-place deployment or a blue/green deployment.
  """
  @type deployment_style() :: %{
          optional(:deployment_option) => deployment_option(),
          optional(:deployment_type) => deployment_type()
        }

  @typedoc """
  Information about when to reroute traffic from an original environment to a
  replacement environment in a blue/green deployment.

  Value values:
  ```
  ["CONTINUE_DEPLOYMENT", "STOP_DEPLOYMENT"]
  ```
  - "CONTINUE_DEPLOYMENT": Register new instances with the load balancer immediately after the
    new application revision is installed on the instances in the replacement environment.
  -"STOP_DEPLOYMENT": Do not register new instances with a load balancer unless traffic
    rerouting is started using ContinueDeployment. If traffic rerouting is not started before
    the end of the specified wait period, the deployment status is changed to Stopped.
  """
  @type action_on_timeout() :: binary()

  @typedoc """
  Information about how traffic is rerouted to instances in a replacement environment in a
  blue/green deployment

  - action_on_timeout - Information about when to reroute traffic from an original environment to a
  replacement environment in a blue/green deployment.
  - wait_time_in_minutes - The number of minutes to wait before the status of a blue/green
    deployment is changed to Stopped if rerouting is not started manually. Applies only to the
    "STOP_DEPLOYMENT" option for action_on_timeout.
  """
  @type deployment_ready_option() :: %{
          optional(:action_on_timeout) => action_on_timeout(),
          optional(:wait_time_in_minutes) => integer()
        }

  @typedoc """
  The method used to add instances to a replacement environment.

  Valid Values
  ```
  ["DISCOVER_EXISTING", "COPY_AUTO_SCALING_GROUP"]
  ```

  - "DISCOVER_EXISTING": Use instances that already exist or will be created manually.
  - "COPY_AUTO_SCALING_GROUP": Use settings from a specified Auto Scaling group to define and create
  instances in a new Auto Scaling group.
  """
  @type action() :: binary()

  @typedoc """
  Information about the instances that belong to the replacement environment in a blue/green
  deployment.

  - action - The method used to add instances to a replacement environment.
  """
  @type green_fleet_provisioning_option() :: %{
          optional(:action) => action()
        }

  @typedoc """
  This parameter only applies if you are using CodeDeploy with Amazon EC2 Auto Scaling.

  Set to true to have CodeDeploy install a termination hook into your Auto Scaling group when you
  create a deployment group. When this hook is installed, CodeDeploy will perform termination
  deployments.
  """
  @type terminate_blue_instances_on_deployment_success() :: boolean()

  @typedoc """
  Information about blue/green deployment options for a deployment group

  - deployment_ready_option - Information about the action to take when newly provisioned instances
    are ready to receive traffic in a blue/green deployment. See `t:deployment_ready_option/0`
  - green_fleet_provisioning_option - Information about how instances are provisioned for a
    replacement environment in a blue/green deployment. See `t:green_fleet_provisioning_option/0`
  - terminate_blue_instances_on_deployment_success - Information about whether to terminate
    instances in the original fleet during a blue/green deployment. See
    `t:terminate_blue_instances_on_deployment_success/0`
  """
  @type blue_green_deployment_configuration() :: %{
          optional(:deployment_ready_option) => deployment_ready_option(),
          optional(:green_fleet_provisioning_option) => green_fleet_provisioning_option(),
          optional(:terminate_blue_instances_on_deployment_success) => terminate_blue_instances_on_deployment_success()
        }

  @typedoc """
  Information about notification triggers for the deployment group

  - trigger_events - The event type or types for which notifications are triggered. A list
    of `t:trigger_event/0`
  - trigger_name - The name of the notification trigger.
  - trigger_target_arn - The Amazon Resource Name (ARN) of the Amazon Simple Notification Service
    topic through which notifications about deployment or instance events are sent.
  """
  @type trigger_configuration() :: %{
          optional(:trigger_events) => [trigger_event()],
          optional(:trigger_name) => binary(),
          optional(:trigger_target_arn) => binary()
        }

  @typedoc """
  A list of `t:trigger_configuration/0`
  """
  @type trigger_configurations() :: [trigger_configuration()]

  @typedoc """
  Some functions take only  an (optional) paging argument. Paging
  is done by passing in the "nextToken" returned by a previous call
  to the API endpoint. The value can be passed in as a keyword list,
  a Map, or a tuple.
  """
  @type paging_options :: [{:next_token, binary()}] | %{optional(:next_token) => binary()} | {:next_token, binary()}

  @typedoc """
   The file type of the application revision.

   Valid Values
   ```
   ["tar", "tgz", "zip", "YAML", "JSON"]
   ```
  """
  @type bundle_type() :: binary()

  @typedoc """
  Information about the location of application artifacts stored in
  Amazon S3.

  - bucket - The name of the Amazon S3 bucket where the application
    revision is stored.
  - bundle_type - The file type of the application revision.
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
          optional(:bundle_type) => bundle_type(),
          optional(:e_tag) => binary(),
          optional(:key) => binary(),
          optional(:version) => binary()
        }

  @typedoc """
  A revision for an AWS Lambda or Amazon ECS deployment that is a YAML-formatted
  or JSON-formatted string. For AWS Lambda and Amazon ECS deployments, the revision
  is the same as the AppSpec file. This method replaces the deprecated
  RawString data type.

  - content -  The YAML-formatted or JSON-formatted revision string. For an AWS Lambda deployment,
    the content includes a Lambda function name, the alias for its original version, and the alias
    for its replacement version. The deployment shifts traffic from the original version of the
    Lambda function to the replacement version. For an Amazon ECS deployment, the content includes
    the task name, information about the load balancer that serves traffic to the container, and
    more. For both types of deployments, the content can specify Lambda functions that run at
    specified hooks, such as BeforeInstall, during a deployment.
  - sha256 - The SHA256 hash value of the revision content.
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
  The type of application revision:

  Valid Values
  ```
  ["S3", "GitHub"," String", "AppSpecContent"]
  ```

  - "S3" - An application revision stored in Amazon S3.
  - "GitHub" - An application revision stored in GitHub (EC2/On-premises deployments only).
  - "String": A YAML-formatted or JSON-formatted string (AWS Lambda deployments only).
  - "AppSpecContent": An AppSpecContent object that contains the contents of an AppSpec file for an
    AWS Lambda or Amazon ECS deployment. The content is formatted as JSON or YAML stored as a
    RawString.

  """
  @type revision_type() :: binary()

  @typedoc """
  Information about the location of an application revision

  - revision_type -
  - s3_location - Information about the location of a revision stored in Amazon S3.
  - git_hub_location - Information about the location of application artifacts stored in GitHub.
  - app_spec_content - The content of an AppSpec file for an AWS Lambda or Amazon ECS deployment.
    The content is formatted as JSON or YAML and stored as a RawString.
  """
  @type revision_location() :: %{
          optional(:revision_type) => revision_type(),
          optional(:s3_location) => s3_location(),
          optional(:git_hub_location) => git_hub_location(),
          optional(:app_spec_content) => app_spec_content()
        }

  @typedoc """
  Information about an EC2 tag filter.

  - key - The tag filter key
  - value - The tag filter value
  - type - The tag filter type. Valid values:
    ```
    ["KEY_ONLY", "VALUE_ONLY", "KEY_AND_VALUE"
    ```
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

  - tag_filters - The tag filter key, type, and value used to identify Amazon EC2 instances in a
    replacement environment for a blue/green deployment. Cannot be used in the same call as
    ec2_tag_set.
  - auto_scaling_groups - The names of one or more Auto Scaling groups to identify a replacement
    environment for a blue/green deployment.
  - ec2_tag_set - Information about the groups of Amazon EC2 instance tags that an instance must be
    identified by in order for it to be included in the replacement environment for a blue/green
    deployment. Cannot be used in the same call as tag_filters.
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
  Specify characteristics of minimum healthy hosts

  - type - The type parameter takes either of the following values:
    - "HOST_COUNT": The value parameter represents the minimum number of healthy instances as an
      absolute value.
    - "FLEET_PERCENT": The value parameter represents the minimum number of healthy instances as a
      percentage of the total number of instances in the deployment. If you specify FLEET_PERCENT,
      at the start of the deployment, AWS CodeDeploy converts the percentage to the equivalent
      number of instances and rounds up fractional instances.
  - value - The value parameter takes an integer. For example, to set a minimum of 95% healthy
    instance, specify a type of FLEET_PERCENT and a value of 95.
  """
  @type minimim_healthy_hosts() :: %{
          optional(:type) => binary(),
          optional(:value) => integer()
        }

  @typedoc """
  A configuration that shifts traffic from one version of a Lambda function or ECS task set to
  another in equal increments, with an equal number of minutes between each increment. The original
  and target Lambda function versions or ECS task sets are specified in the deployment's AppSpec
  file

  - linear_interval - The number of minutes between each incremental traffic shift of a
    TimeBasedLinear deployment.
  - linear_percentage - The percentage of traffic that is shifted at the start of each increment of
    a TimeBasedLinear deployment.
  """
  @type time_based_linear() :: %{
          optional(:linear_interval) => integer(),
          optional(:linear_percentage) => integer()
        }

  @typedoc """
  A configuration that shifts traffic from one version of a Lambda function or ECS task set to
  another in two increments. The original and target Lambda function versions or ECS task sets are
  specified in the deployment's AppSpec file

  - canary_interval -The number of minutes between the first and second traffic shifts of a
    TimeBasedCanary deployment.
  - canary_percentage - The percentage of traffic to shift in the first increment of a
    TimeBasedCanary deployment.
  """
  @type time_based_canary :: %{
          optional(:canary_interval) => integer(),
          optional(:canary_percentage) => integer()
        }

  @typedoc """
  The configuration that specifies how the deployment traffic is routed

  - type - The type of traffic shifting (TimeBasedCanary or TimeBasedLinear) used by a deployment
    configuration. Valid values are "TimeBasedCanary", "TimeBasedLinear" or "AllAtOnce"
  - time_based_canary - `t:time_based_canary/0`
  - time_based_linear - `t:time_based_linear/0`
  """
  @type traffic_routing_config() :: %{
          optional(:type) => binary(),
          optional(:time_based_canary) => time_based_canary(),
          optional(:time_based_linear) => time_based_linear()
        }

  @typedoc """
  Configure the ZonalConfig object if you want AWS CodeDeploy to deploy your application to one
  Availability Zone at a time, within an AWS Region. By deploying to one Availability Zone at a
  time, you can expose your deployment to a progressively larger audience as confidence in the
  deployment's performance and viability grows. If you don't configure the ZonalConfig object,
  CodeDeploy deploys your application to a random selection of hosts across a Region.

  - first_zone_monitor_duration_in_seconds - The period of time, in seconds, that CodeDeploy must
    wait after completing a deployment to the first Availability Zone. CodeDeploy will wait this
    amount of time before starting a deployment to the second Availability Zone. You might set this
    option if you want to allow extra bake time for the first Availability Zone. If you don't
    specify a value for firstZoneMonitorDurationInSeconds, then CodeDeploy uses the
    monitorDurationInSeconds value for the first Availability Zone.
  - minimim_healthy_hosts_per_zone - The number or percentage of instances that must remain
    available per Availability Zone during a deployment. `t:minimim_healthy_hosts/0`
  - monitor_duration_in_seconds - The period of time, in seconds, that CodeDeploy must wait after
    completing a deployment to an Availability Zone. CodeDeploy will wait this amount of time before
    starting a deployment to the next Availability Zone. Consider adding a monitor duration to give
    the deployment some time to prove itself (or 'bake') in one Availability Zone before it is
    released in the next zone. If you don't specify a monitor_duration_in_seconds, CodeDeploy starts
    deploying to the next Availability Zone immediately.
  """
  @type zonal_config() :: %{
          optional(:first_zone_monitor_duration_in_seconds) => integer(),
          optional(:minimim_healthy_hosts_per_zone) => minimim_healthy_hosts(),
          optional(:monitor_duration_in_seconds) => integer()
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
  Information about how AWS CodeDeploy handles files that already exist in a deployment target
  location but weren't part of the previous successful deployment.

  Takes any of the following values:

  - "DISALLOW": The deployment fails. This is also the default behavior if no option is specified.
  - "OVERWRITE": The version of the file from the application revision currently being deployed
    replaces the version already on the instance.
  - "RETAIN": The version of the file already on the instance is kept and used as part of the new
    deployment.
  """
  @type file_exists_behaviour() :: binary()

  @typedoc """
  Optional input to the `create_deployment/2` function

  The required application name is passed in as the first argument
  separately from the map.

  - deployment_group_name - The name of the deployment group
  - revision - The type and location of the revision to deploy
  - deployment_config_name - The name of a deployment configuration associated with the user or AWS
    account. If not specified, the value configured in the deployment group is used as the default.
    If the deployment group does not have a deployment configuration associated with it,
    CodeDeployDefault.OneAtATime is used by default.
  - description - A comment about the deployment
  - ignore_application_stop_failures - boolean value that has the following implications:
    - If true, then if an ApplicationStop, BeforeBlockTraffic, or AfterBlockTraffic deployment
    lifecycle event to an instance fails, then the deployment continues to the next deployment
    lifecycle event. For example, if ApplicationStop fails, the deployment continues with
    DownloadBundle. If BeforeBlockTraffic fails, the deployment continues with BlockTraffic. If
    AfterBlockTraffic fails, the deployment continues with ApplicationStop.
    - If false or not specified, then if a lifecycle event fails during a deployment to an instance,
    that deployment fails. If deployment to that instance is part of an overall deployment and the
    number of healthy hosts is not less than the minimum number of healthy hosts, then a deployment
    to the next instance is attempted.
    - During a deployment, the AWS CodeDeploy agent runs the scripts specified for ApplicationStop,
    BeforeBlockTraffic, and AfterBlockTraffic in the AppSpec file from the previous successful
    deployment. (All other scripts are run from the AppSpec file in the current deployment.) If one
    of these scripts contains an error and does not run successfully, the deployment can fail.
    - If the cause of the failure is a script from the last successful deployment that will never run
    successfully, create a new deployment and use ignoreApplicationStopFailures to specify that the
    ApplicationStop, BeforeBlockTraffic, and AfterBlockTraffic failures should be ignored.
  - target_instances - Information about the instances that belong to the replacement environment in
    a blue/green deployment
  - auto_rollback_configuration - Configuration information for an automatic rollback that is added
    when a deployment is created
  - update_outdated_instances_only - Indicates whether to deploy to all instances or only to
    instances that are not running the latest application revision.
  - file_exists_behavior - Information about how AWS CodeDeploy handles files that already exist in
    a deployment target location but weren't part of the previous successful deployment.
  - override_alarm_configuration -
  """
  @type deployment_optional_details() :: %{
          optional(:deployment_group_name) => deployment_group_name(),
          optional(:revision) => revision_location(),
          optional(:deployment_config_name) => deployment_config_name(),
          optional(:description) => binary(),
          optional(:ignore_application_stop_failures) => boolean(),
          optional(:target_instances) => target_instances(),
          optional(:auto_rollback_configuration) => auto_rollback_configuration(),
          optional(:update_outdated_instances_only) => boolean(),
          optional(:file_exists_behavior) => file_exists_behaviour(),
          optional(:override_alarm_configuration) => alarm_configuration()
        }

  @typedoc """
  A filter value used to filter deployment targets by current target status

  Valid Values

  ```
  ["Failed", "InProgress", "Pending", "Ready", "Skipped", "Succeeded", "Unknown"]
  ```
  """
  @type target_status_values() :: binary()

  @typedoc """
  A filter value used to filter deployment targets based on current label

  Valid Values

  ```
  ["Blue", "Green"`]
  ```
  """
  @type service_instance_label_values() :: binary()

  @typedoc """
  Filter used with `list_deployment_targets/1`

  - target_status - filter deployment targets by current target status
  - service_instance_label - filter deployment targets based on current label
  """
  @type target_filters() :: %{
          optional(:target_status) => [target_status_values()],
          optional(:service_instance_label) => [service_instance_label_values()]
        }

  @typedoc """
  Optional parameters for the `list_deployment_targets/1` function

  - next_token - A token identifier returned from the previous `list_deployment_targets/1` call. It
    can be used to return the next set of deployment targets in the list.
  - target_filters - A key used to filter the returned targets.
  """
  @type list_deployment_targets_optional_details() :: %{
          optional(:next_token) => binary(),
          optional(:target_filters) => target_filters()
        }

  @typedoc """
  Optional parameters for the `list_tags_for_resource/2` function
  """
  @type list_tags_for_resource_optional_details() :: %{
          optional(:next_token) => binary()
        }

  @typedoc """
  Optional parameters to the function `register_application_revision/3`
  """
  @type register_application_revision_optional_details() :: %{
          optional(:description) => binary()
        }

  @typedoc """
  Optional arguments to the `create_deployment_config/2` function

  - minimim_healthy_hosts - The minimum number of healthy instances that should be available at any
    time during the deployment. There are two parameters expected in the input: type and value.
  - traffic_routing_config - The configuration that specifies how the deployment traffic is routed
  - compute_platform - The destination platform type for the deployment (Lambda, Server, or ECS)
  - zonal_config - Configure the ZonalConfig object if you want AWS CodeDeploy to deploy your
    application to one Availability Zone at a time, within an AWS Region.
  """
  @type deployment_config_optional_details() :: %{
          optional(:minimim_healthy_hosts) => minimim_healthy_hosts(),
          optional(:traffic_routing_config) => traffic_routing_config(),
          optional(:compute_platform) => compute_platform(),
          optional(:zonal_config) => zonal_config()
        }

  @typedoc """
  Whether to list revisions based on whether the revision is the target revision of a deployment
  group.

  Valid values
  ```
  ["include", "exclude", "ignore"]
  ```

  - "include": List revisions that are target revisions of a deployment group.
  - "exclude": Do not list revisions that are target revisions of a deployment group.
  - "ignore": List all revisions.
  """
  @type list_state_filter_action() :: binary()

  @typedoc """
  The column name to use to sort the list results.

  Valid values
  ```
  ["registerTime", "firstUsedTime", "lastUsedTime"]
  ```

  - "registerTime": Sort by the time the revisions were registered with AWS CodeDeploy.
  - "firstUsedTime": Sort by the time the revisions were first used in a deployment.
  - "lastUsedTime": Sort by the time the revisions were last used in a deployment.

  If not specified or set to null, the results are returned in an arbitrary order.
  """
  @type application_revision_sort_by() :: binary()

  @typedoc """
  The order in which to sort the list results.

  Valid values
  ```
  ["ascending", "descending"]
  ```

  - "ascending": ascending order.
  - "descending": descending order.
  """
  @type sort_order() :: binary()

  @typedoc """
  Optional arguments to the `list_application_revisions/2` function

  - deployed - Whether to list revisions based on whether the revision is the target revision of a
    deployment grou
  - next_token - An identifier returned from the previous `list_application_revisions/2` call. It
    can be used to return the next set of applications in the list.
  - s3_bucket - An Amazon S3 bucket name to limit the search for revisions. If set to nil (or not
    provided), all of the user's buckets are searched.
  - s3_key_prefix - A key prefix for the set of Amazon S3 objects to limit the search for revisions
  - sort_by - The column name to use to sort the list results
  - sort_order - The order in which to sort the list results
  """
  @type list_applications_revisions_optional_details() :: %{
          optional(:deployed) => list_state_filter_action(),
          optional(:next_token) => binary(),
          optional(:s3_bucket) => binary(),
          optional(:s3_key_prefix) => binary(),
          optional(:sort_by) => application_revision_sort_by(),
          optional(:sort_order) => sort_order()
        }

  @typedoc """
  The registration status of the on-premises instances.

  Valid Values
  ```
  ["Deregistered"  "Registered"]
  ```

  - "Deregistered": Include deregistered on-premises instances in the resulting list.
  - "Registered": Include registered on-premises instances in the resulting list.
  """
  @type registration_status() :: binary()

  @typedoc """
  Optional parameters for the function `list_on_premises_instances/1`

  - next_token - An identifier returned from the previous `list_on_premises_instances/1` call. It can be
    used to return the next set of on-premises instances in the list.
  - registration_status - The registration status of the on-premises instances. See
    `t:registration_status/0`
  - tag_filters - The on-premises instance tags that are used to restrict the on-premises instance
    names returned. See `t:tag_filter_list/0`.
  """
  @type list_on_premises_instances_optional_details() :: %{
          optional(:next_token) => binary(),
          optional(:registration_status) => registration_status(),
          optional(:tag_filters) => tag_filter_list()
        }

  @typedoc """
  Information about a Classic Load Balancer in Elastic Load Balancing to use in a deployment.
  Instances are registered directly with a load balancer, and traffic is routed to the load
  balancer.

  - name - For blue/green deployments, the name of the Classic Load Balancer that is used to route
    traffic from original instances to replacement instances in a blue/green deployment. For
    in-place deployments, the name of the Classic Load Balancer that instances are deregistered from
    so they are not serving traffic during a deployment, and then re-registered with after the
    deployment is complete.
  """
  @type elb_info() :: %{
          optional(:name) => binary()
        }

  @typedoc """
  Information about a target group in Elastic Load Balancing to use in a deployment. Instances are
  registered as targets in a target group, and traffic is routed to the target group.

  - name - For blue/green deployments, the name of the target group that instances in the original
    environment are deregistered from, and instances in the replacement environment are registered
    with. For in-place deployments, the name of the target group that instances are deregistered
    from, so they are not serving traffic during a deployment, and then re-registered with after the
    deployment is complete.
  """
  @type target_group_info() :: %{
          optional(:name) => binary()
        }

  @typedoc """
  Information about a listener. The listener contains the path used to route traffic that is
  received from the load balancer to a target group.

  - listener_arns - The Amazon Resource Name (ARN) of one listener. The listener identifies the
    route between a target group and a load balancer. This is an array of strings with a maximum
    size of one.
  """
  @type traffic_route() :: %{
          optional(:listener_arns) => [binary()]
        }

  @typedoc """
  Information about two target groups and how traffic is routed during an Amazon ECS deployment. An
  optional test traffic route can be specified.

  - prod_traffic_route - The path used by a load balancer to route production traffic when an Amazon
    ECS deployment is complete.
  - target_groups - One pair of target groups. One is associated with the original task set. The
    second is associated with the task set that serves traffic after the deployment is complete.
  - test_traffic_route - An optional path used by a load balancer to route test traffic after an
    Amazon ECS deployment. Validation can occur while test traffic is served during a deployment.
  """
  @type target_group_pair_info() :: %{
          optional(:prod_traffic_route) => traffic_route(),
          optional(:target_groups) => [target_group_info()],
          optional(:test_traffic_route) => traffic_route()
        }

  @typedoc """
  Contains the service and cluster names used to identify an Amazon ECS deployment's target

  - cluster_name - The name of the cluster that the Amazon ECS service is associated with.
  - service_name - The name of the target Amazon ECS service
  """
  @type ecs_service() :: %{
          optional(:cluster_name) => binary(),
          optional(:service_name) => binary()
        }

  @typedoc """
  A list of `t:ecs_service/0`
  """
  @type ecs_services() :: [ecs_service()]

  @typedoc """
  Information about the Elastic Load Balancing load balancer or target group used in a deployment.

  You can use load balancers and target groups in combination. For example, if you have two Classic
  Load Balancers, and five target groups tied to an Application Load Balancer, you can specify the
  two Classic Load Balancers in elb_info_list, and the five target groups in target_group_info_list.

  - elb_info_list - An array that contains information about the load balancers to use for load
    balancing in a deployment. If you're using Classic Load Balancers, specify those load balancers
    in this array. You can add up to 10 load balancers to the array. If you're using Application
    Load Balancers or Network Load Balancers, use the target_group_info_list array instead of this one.
  - target_group_info_list - An array that contains information about the target groups to use for
    load balancing in a deployment. If you're using Application Load Balancers and Network Load
    Balancers, specify their associated target groups in this array. You can add up to 10 target
    groups to the array. If you're using Classic Load Balancers, use the elb_info_list array instead
    of this one.
  - target_group_pair_info_list - The target group pair information. This is a list of
    `target_group_pair_info/0` objects with a maximum size of one.
  """
  @type load_balancer_info() :: %{
          optional(:elb_info_list) => [elb_info()],
          optional(:target_group_info_list) => [target_group_info()],
          optional(:target_group_pair_info_list) => [target_group_pair_info()]
        }

  @typedoc """
  Optional arguments to the `create_deployment_group/4` function

  - deployment_config_name - If specified, the deployment configuration name can be either one of
    the predefined configurations provided with AWS CodeDeploy or a custom deployment configuration
    that you create by calling the create deployment configuration operation.
  - ec2_tag_filters -The Amazon EC2 tags on which to filter. The deployment group includes Amazon
    EC2 instances with any of the specified tags. Cannot be used in the same call as ec2_tag_set.
  - on_premises_instance_tag_filters - The on-premises instance tags on which to filter. The
    deployment group includes on-premises instances with any of the specified tags. Cannot be used
    in the same call as on_premises_tag_set.
  - auto_scaling_groups - A list of associated Amazon EC2 Auto Scaling groups
  - trigger_configurations - Information about triggers to create when the deployment group is
    created.
  - alarm_configuration - Information to add about Amazon CloudWatch alarms when the deployment
    group is created
  - auto_rollback_configuration - Configuration information for an automatic rollback that is added
    when a deployment group is created.
  - outdated_instances_strategy - Indicates what happens when new Amazon EC2 instances are launched
    mid-deployment and do not receive the deployed application revision.
  - deployment_style - Information about the type of deployment, in-place or blue/green, that you
    want to run and whether to route deployment traffic behind a load balancer
  - blue_green_deployment_configuration - Information about blue/green deployment options for a
    deployment group.
  - load_balancer_info - Information about the load balancer used in a deployment
  - ec2_tag_set - Information about groups of tags applied to Amazon EC2 instances. The deployment
    group includes only Amazon EC2 instances identified by all the tag groups. Cannot be used in the
    same call as ec2_tag_filters
  - ecs_services - The target Amazon ECS services in the deployment group. This applies only to
    deployment groups that use the Amazon ECS compute platform. A target Amazon ECS service is
    specified as an Amazon ECS cluster and service name pair using the format
    `<clustername>:<servicename>`
  - on_premises_tag_set - Information about groups of tags applied to on-premises instances. The
    deployment group includes only on-premises instances identified by all of the tag groups. Cannot
    be used in the same call as on_premises_instance_tag_filters.
  - tags - The metadata that you apply to CodeDeploy deployment groups to help you organize and
    categorize them. Each tag consists of a key and an optional value, both of which you define.
  - termination_hook_enabled - This parameter only applies if you are using CodeDeploy with Amazon
    EC2 Auto Scaling.
  """
  @type deployment_group_optional_details() :: %{
          optional(:deployment_config_name) => deployment_config_name(),
          optional(:ec2_tag_filters) => [ec2_tag_filter()],
          optional(:on_premises_instance_tag_filters) => [tag_filter_list()],
          optional(:auto_scaling_groups) => [auto_scaling_group()],
          optional(:trigger_configurations) => trigger_configurations(),
          optional(:alarm_configuration) => alarm_configuration(),
          optional(:auto_rollback_configuration) => auto_rollback_configuration(),
          optional(:outdated_instances_strategy) => outdated_instances_strategy(),
          optional(:deployment_style) => deployment_style(),
          optional(:blue_green_deployment_configuration) => blue_green_deployment_configuration(),
          optional(:load_balancer_info) => load_balancer_info(),
          optional(:ec2_tag_set) => ec2_tag_set(),
          optional(:ecs_services) => ecs_services(),
          optional(:on_premises_tag_set) => on_premises_tag_set(),
          optional(:tags) => tags(),
          optional(:termination_hook_enabled) => boolean()
        }
  @typedoc """
  Information about a time range.

  - start -The start time of the time range. Specify nil to leave the start time open-ended.
  - end - The end time of the time range. Specify nil to leave the end time open-ended.
  """
  @type time_range :: %{optional(:start) => binary(), optional(:end) => binary()}

  @typedoc """
  Deployment status states

  Valid Values
  ```
  ["Created","Queued","InProgress","Baking","Succeeded","Failed","Stopped", "Ready"]
  ```

  - "Created": Include created deployments in the resulting list.
  - "Queued": Include queued deployments in the resulting list.
  - "In Progress": Include in-progress deployments in the resulting list.
  - "Succeeded": Include successful deployments in the resulting list.
  - "Failed": Include failed deployments in the resulting list.
  - "Stopped": Include stopped deployments in the resulting list.

  """
  @type include_only_statuses() :: binary()

  @typedoc """
  Optional input to the `list_deployments/1` function

  Prefer using the map version. The keyword list was defined in
  an earlier version of the library.

  - application_name - The name of an AWS CodeDeploy application associated with the user or AWS
    account. If application_name is specified, then deployment_group_name must be specified. If it
    is not specified, then deployment_group_name must not be specified.
  - deployment_group_name - The name of a deployment group for the specified application. If
    deployment_group_name is specified, then application_name must be specified. If it is not
    specified, then applicationName must not be specified.
  - include_only_statuses - A subset of deployments to list by status
  - create_time_range - A time range (start and end) for returning a subset of the list of
    deployments.
  - next_token - An identifier returned from the previous `list_deployments/1` call. It can be used
    to return the next set of deployments in the list.
  """
  @type list_deployments_optional_details() ::
          [
            application_name: application_name(),
            deployment_group_name: deployment_group_name(),
            include_only_statuses: [include_only_statuses()],
            create_time_range: time_range(),
            next_token: binary
          ]
          | %{
              optional(:application_name) => application_name(),
              optional(:deployment_group_name) => deployment_group_name(),
              optional(:include_only_statuses) => [include_only_statuses()],
              optional(:create_time_range) => time_range(),
              optional(:next_token) => binary()
            }

  @typedoc """
  Indicates an instance in the original environment ("Blue") or an instance
  in a replacement environment ("Green").

  Valid Values: "Blue" or "Green"
  """
  @type instance_type_filter() :: binary()

  @typedoc """
  Indicates an instance's status.

  Valid values
  ```
  ["Pending", "InProgress", "Succeeded", "Failed", "Skipped", "Unknown"]
  ```

  - "Pending": Include those instances with pending deployments.
  - "InProgress": Include those instances where deployments are still in progress.
  - "Succeeded": Include those instances with successful deployments.
  - "Failed": Include those instances with failed deployments.
  - "Skipped": Include those instances with skipped deployments.
  - "Unknown": Include those instances with deployments in an unknown state.
  """
  @type instance_status_filter() :: binary()

  @typedoc """
  Optional input to the `list_deployment_instances/2` function

  Prefer using the map version. The keyword list was defined in
  an earlier version of the library.

  - instance_status_filter - A subset of instances to list by status. See `t:instance_status_filter/0`.
  - instance_type_filter - The set of instances in a blue/green deployment, either those in the
    original environment ("BLUE") or those in the replacement environment ("GREEN"), for which you
    want to view instance information.
  - next_token - An identifier returned from the previous  `list_deployment_instances/2` call. It can be
    used to return the next set of deployment instances in the list.
  """
  @type list_deployment_instances_optional_details() ::
          [
            instance_status_filter: [instance_status_filter()],
            instance_type_filter: [instance_type_filter()],
            next_token: binary
          ]
          | %{
              optional(:instance_status_filter) => [instance_status_filter()],
              optional(:instance_type_filter) => [instance_type_filter()],
              optional(:next_token) => binary()
            }

  @doc """
  Lists information about revisions for an application

  ## Examples

      iex> list_application_revisions = %{
      ...>   s3_bucket: "CodeDeployDemoBucket",
      ...>   deployed: "exclude",
      ...>   sort_by: "lastUsedTime",
      ...>   sort_order: "descending"
      ...> }
      iex> ExAws.CodeDeploy.list_application_revisions("WordPress_App", list_application_revisions)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "WordPress_App",
          "deployed" => "exclude",
          "s3Bucket" => "CodeDeployDemoBucket",
          "sortBy" => "lastUsedTime",
          "sortOrder" => "descending"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListApplicationRevisions"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_application_revisions(application_name(), list_applications_revisions_optional_details()) ::
          ExAws.Operation.JSON.t()
  def list_application_revisions(application_name, list_applications_revisions \\ %{}) do
    list_applications_revisions
    |> Utils.camelize_map()
    |> Map.merge(%{"applicationName" => application_name})
    |> request(:list_application_revisions)
  end

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
  @spec list_applications(paging_options()) :: ExAws.Operation.JSON.t()
  def list_applications(opts \\ []) do
    opts |> Utils.build_paging() |> request(:list_applications)
  end

  @doc """
  Adds tags to on-premises instances.

  ## Examples

      iex> tags = [%{key: "key1", value: "value"}, %{key: "key2", value: "value"}]
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
  @spec add_tags_to_on_premises_instances([instance_name()], [tag()] | [primitive_tag()]) :: ExAws.Operation.JSON.t()
  def add_tags_to_on_premises_instances(instance_names, tags) when is_list(instance_names) and is_list(tags) do
    %{instance_names: instance_names, tags: Utils.normalize_tags(tags)}
    |> Utils.camelize_map()
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
  Gets information about one or more application revisions

  The maximum number of application revisions that can be returned is 25.

  ## Examples

      iex> revisions = [
      ...>%{
      ...>  git_hub_location: %{commit_id: "fa85936EXAMPLEa31736c051f10d77297EXAMPLE",
      ...>  repository: "my-github-token/my-repository"},
      ...>  revision_type: "GitHub"
      ...> }]
      iex> ExAws.CodeDeploy.batch_get_application_revisions("my-codedeploy-application", revisions)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "my-codedeploy-application",
          "revisions" => [
            %{
              "gitHubLocation" => %{
                "commitId" => "fa85936EXAMPLEa31736c051f10d77297EXAMPLE",
                "repository" => "my-github-token/my-repository"
              },
              "revisionType" => "GitHub"
            }
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetApplicationRevisions"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_application_revisions(application_name(), [revision_location()]) :: ExAws.Operation.JSON.t()
  def batch_get_application_revisions(application_name, revisions) when is_list(revisions) do
    %{application_name: application_name, revisions: revisions}
    |> Utils.camelize_map()
    |> request(:batch_get_application_revisions)
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
  Returns an array of one or more targets associated with a deployment. This method works with all
  compute types and should be used instead of the deprecated BatchGetDeploymentInstances. The
  maximum number of deployment target IDs you can specify is 25.

  The type of targets returned depends on the deployment's compute platform or deployment method:

  - EC2/On-premises: Information about Amazon EC2 instance targets.
  - AWS Lambda : Information about Lambda functions targets.
  - Amazon ECS: Information about Amazon ECS service targets.
  - CloudFormation: Information about targets of blue/green deployments initiated by a
    CloudFormation stack update.

  ## Examples

      iex> ExAws.CodeDeploy.batch_get_deployment_targets("d-1A2B3C4D5", ["i-01a2b3c4d5e6f1111"])
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "deploymentId" => "d-1A2B3C4D5",
          "targetIds" => ["i-01a2b3c4d5e6f1111"]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.BatchGetDeploymentTargets"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec batch_get_deployment_targets(deployment_id(), target_ids()) :: ExAws.Operation.JSON.t()
  def batch_get_deployment_targets(deployment_id, target_ids) when is_list(target_ids) do
    %{
      "deploymentId" => deployment_id,
      "targetIds" => target_ids
    }
    |> request(:batch_get_deployment_targets)
  end

  @doc """
  For a blue/green deployment, starts the process of rerouting traffic.

  Start the process of rerouting traffic from instances in the original environment to instances in
  the replacement environment without waiting for a specified wait time to elapse. (Traffic
  rerouting, which is achieved by registering instances in the replacement environment with the load
  balancer, can start as soon as all instances have a status of Ready.)

  The `deployment_wait_type` is optional. If any value other than "READY_WAIT" or "TERMINATION_WAIT"
  is provided then it is not sent with the API request.

  ## Examples

      iex> ExAws.CodeDeploy.continue_deployment("d-1234")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "d-1234"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ContinueDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }

      iex> ExAws.CodeDeploy.continue_deployment("d-1234", "TERMINATION_WAIT")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "deploymentId" => "d-1234",
          "deploymentWaitType" => "TERMINATION_WAIT"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ContinueDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec continue_deployment(deployment_id(), nil | deployment_wait_type()) :: ExAws.Operation.JSON.t()
  def continue_deployment(deployment_id, deployment_wait_type \\ nil) do
    case deployment_wait_type in @valid_deployment_wait_types do
      false -> %{"deploymentId" => deployment_id}
      _ -> %{"deploymentId" => deployment_id, "deploymentWaitType" => deployment_wait_type}
    end
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

  ## Examples

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
    %{application_name: application_name, compute_platform: compute_platform, tags: Utils.normalize_tags(tags)}
    |> Utils.camelize_map()
    |> request(:create_application)
  end

  @doc """
  Deploys an application revision through the specified deployment group.

  Caller is responsible for defining the deployment_details in a manner that
  matches what Amazon expects. See unit test.

  ## Examples

      iex> deployment_details = %{
      ...>   deployment_group_name: "dep-01",
      ...>   auto_rollback_configuration: %{
      ...>    enabled: true,
      ...>    events: ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
      ...>   },
      ...>   revision: %{
      ...>    git_hub_location: %{commit_id: "fa85936EXAMPLEa31736c051f10d77297EXAMPLE",
      ...>    repository: "my-github-token/my-repository"},
      ...>    revision_type: "GitHub"
      ...>   }
      ...> }
      iex> ExAws.CodeDeploy.create_deployment("my-app", deployment_details)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "my-app",
          "autoRollbackConfiguration" => %{
            "enabled" => true,
            "events" => ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
          },
          "deploymentGroupName" => "dep-01",
          "revision" => %{
            "gitHubLocation" => %{
              "commitId" => "fa85936EXAMPLEa31736c051f10d77297EXAMPLE",
              "repository" => "my-github-token/my-repository"
            },
            "revisionType" => "GitHub"
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec create_deployment(application_name(), deployment_optional_details()) :: ExAws.Operation.JSON.t()
  def create_deployment(application_name, deployment_details \\ %{}) do
    deployment_details
    |> Utils.camelize_map()
    |> Map.merge(%{"applicationName" => application_name})
    |> request(:create_deployment)
  end

  @doc """
  Creates a deployment configuration

  ## Examples

      iex> ExAws.CodeDeploy.create_deployment_config("deploy_config1")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentConfigName" => "deploy_config1"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }


      iex> deployment_config_details = %{minimim_healthy_hosts: %{type: "HOST_COUNT", value: 2}}
      iex> ExAws.CodeDeploy.create_deployment_config("deploy_config1", deployment_config_details)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "deploymentConfigName" => "deploy_config1",
          "minimimHealthyHosts" => %{"type" => "HOST_COUNT", "value" => 2}
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateDeployment"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec create_deployment_config(deployment_config_name(), deployment_config_optional_details()) ::
          ExAws.Operation.JSON.t()
  def create_deployment_config(deployment_config_name, deployment_config_details \\ %{}) do
    deployment_config_details
    |> Utils.camelize_map()
    |> Map.merge(%{"deploymentConfigName" => deployment_config_name})
    |> request(:create_deployment)
  end

  @doc """
  Creates a deployment group to which application revisions are deployed

  ## Examples

      iex> application_name = "WordPress_App"
      iex> deployment_group_name = "WordPress_DG"
      iex> service_role_arn = "arn:aws:iam::123456789012:role/CodeDeployDemoRole"
      iex> deployment_group_details = %{
      ...>   auto_scaling_groups: ["CodeDeployDemo-ASG"],
      ...>   deployment_config_name: "CodeDeployDefault.OneAtATime",
      ...>   ec2_tag_filters: [%{key: "Name", value: "CodeDeployDemo", type: "KEY_AND_VALUE"}]
      ...> }
      iex> ExAws.CodeDeploy.create_deployment_group(application_name, deployment_group_name, service_role_arn, deployment_group_details)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "WordPress_App",
          "autoScalingGroups" => ["CodeDeployDemo-ASG"],
          "deploymentConfigName" => "CodeDeployDefault.OneAtATime",
          "deploymnentGroupName" => "WordPress_DG",
          "ec2TagFilters" => [
            %{"Key" => "Name", "Type" => "KEY_AND_VALUE", "Value" => "CodeDeployDemo"}
          ],
          "serviceRoleArn" => "arn:aws:iam::123456789012:role/CodeDeployDemoRole"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.CreateDeploymentGroup"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec create_deployment_group(
          application_name(),
          deployment_group_name(),
          service_role_arn(),
          deployment_group_optional_details()
        ) :: ExAws.Operation.JSON.t()
  def create_deployment_group(application_name, deployment_group_name, service_role_arn, deployment_group_details) do
    deployment_group_details
    |> Utils.camelize_map()
    |> Map.merge(%{
      "applicationName" => application_name,
      "deploymnentGroupName" => deployment_group_name,
      "serviceRoleArn" => service_role_arn
    })
    |> request(:create_deployment_group)
  end

  @doc """
  Deletes an application.

  application_name: The name of an AWS CodeDeploy application associated with the applicable IAM
  user or AWS account.

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

  A deployment configuration cannot be deleted if it is currently in use. Predefined configurations
  cannot be deleted.

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
  Deletes resources linked to an external ID. This action only applies if you have configured
  blue/green deployments through AWS CloudFormation.

  It is not necessary to call this action directly. CloudFormation calls it on your behalf when it
  needs to delete stack resources. This action is offered publicly in case you need to delete
  resources to comply with General Data Protection Regulation (GDPR) requirements.

  ## Examples

      iex> ExAws.CodeDeploy.delete_resources_by_external_id("external-12345")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"externalId" => "external-12345"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.DeleteResourcesByExternalId"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec delete_resources_by_external_id(binary()) :: ExAws.Operation.JSON.t()
  def delete_resources_by_external_id(external_id) do
    %{"externalId" => external_id}
    |> request(:delete_resources_by_external_id)
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
          {"x-amz-target", "CodeDeploy_20141006.BatchGetDeploymentInstances"},
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
    |> request(:batch_get_deployment_instances)
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
  @spec list_deployments(list_deployments_optional_details()) :: ExAws.Operation.JSON.t()
  def list_deployments(opts \\ %{}) do
    opts |> Utils.keyword_to_map() |> Utils.camelize_map() |> request(:list_deployments)
  end

  @doc """
  Returns an array of target IDs that are associated a deployment

      iex> target_filters = %{target_filters: %{target_status: ["Failed", "InProgress"]}}
      iex> ExAws.CodeDeploy.list_deployment_targets("d-A1B2C3111", target_filters)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "deploymentId" => "d-A1B2C3111",
          "targetFilters" => %{"TargetStatus" => ["Failed", "InProgress"]}
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListDeploymentTargets"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_deployment_targets(deployment_id(), list_deployment_targets_optional_details()) :: ExAws.Operation.JSON.t()
  def list_deployment_targets(deployment_id, opts \\ %{}) do
    opts
    |> Utils.camelize_map()
    |> Map.merge(%{"deploymentId" => deployment_id})
    |> request(:list_deployment_targets)
  end

  @doc """
  Lists the names of stored connections to GitHub accounts

  ## Examples

      iex> ExAws.CodeDeploy.list_git_hub_account_token_names()
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListGitHubAccountTokenNames"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_git_hub_account_token_names(paging_options()) :: ExAws.Operation.JSON.t()
  def list_git_hub_account_token_names(opts \\ []) do
    opts |> Utils.build_paging() |> request(:list_git_hub_account_token_names)
  end

  @doc """
  Gets a list of names for one or more on-premises instances.

  Unless otherwise specified, both registered and deregistered on-premises instance names are
  listed. To list only registered or deregistered on-premises instance names, use the registration
  status parameter.

  ## Examples

      iex> opts = %{
      ...>   registration_status: "Registered",
      ...>   tag_filters: [%{key: "Name", value: "CodeDeployDemo-OnPrem", type: "KEY_AND_VALUE"}]
      ...> }
      iex> ExAws.CodeDeploy.list_on_premises_instances(opts)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "registrationStatus" => "Registered",
          "tagFilters" => [
            %{
              "Key" => "Name",
              "Type" => "KEY_AND_VALUE",
              "Value" => "CodeDeployDemo-OnPrem"
            }
          ]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListOnPremisesInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_on_premises_instances(list_on_premises_instances_optional_details()) :: ExAws.Operation.JSON.t()
  def list_on_premises_instances(opts \\ %{}) do
    opts
    |> Utils.camelize_map()
    |> request(:list_on_premises_instances)
  end

  @doc """
  Returns a list of tags for the resource identified by a specified Amazon Resource Name (ARN). Tags
  are used to organize and categorize your CodeDeploy resources.

  ## Examples

      iex> resource_arn = "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
      iex> ExAws.CodeDeploy.list_tags_for_resource(resource_arn)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "resourceArn" => "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListTagsForResource"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }

      iex> resource_arn = "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
      iex> ExAws.CodeDeploy.list_tags_for_resource(resource_arn, %{next_token: "abcd123EXAMPLE"})
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "nextToken" => "abcd123EXAMPLE",
          "resourceArn" => "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.ListTagsForResource"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec list_tags_for_resource(resource_arn(), list_tags_for_resource_optional_details()) :: ExAws.Operation.JSON.t()
  def list_tags_for_resource(resource_arn, opts \\ %{}) do
    opts
    |> Utils.camelize_map()
    |> Map.merge(%{"resourceArn" => resource_arn})
    |> request(:list_tags_for_resource)
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

  ## Examples

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
  Gets information about a deployment configuration. See `create_deployment/2`

  ## Examples

      iex> ExAws.CodeDeploy.get_deployment_config("deploy-config")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentConfigName" => "deploy-config"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetDeploymentConfig"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
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
  Returns information about a deployment target

  ## Examples

      iex> ExAws.CodeDeploy.get_deployment_target("d-7539MBT7C", "i-49663TARGET")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "d-7539MBT7C", "targetId" => "i-49663TARGET"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetDeploymentTarget"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_deployment_target(deployment_id(), target_id()) :: ExAws.Operation.JSON.t()
  def get_deployment_target(deployment_id, target_id) do
    %{"deploymentId" => deployment_id, "targetId" => target_id}
    |> request(:get_deployment_target)
  end

  @doc """
  Gets information about an on-premises instance

  ## Examples

      iex> ExAws.CodeDeploy.get_on_premises_instance("AssetTag12010298EX")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"instanceName" => "AssetTag12010298EX"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.GetOnPremisesInstance"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec get_on_premises_instance(instance_name()) :: ExAws.Operation.JSON.t()
  def get_on_premises_instance(instance_name) do
    %{"instanceName" => instance_name}
    |> request(:get_on_premises_instance)
  end

  @doc """
  Lists the instance for a deployment associated with the applicable IAM user or AWS account.

  ## Examples

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
  @spec list_deployment_instances(deployment_id(), list_deployment_instances_optional_details()) ::
          ExAws.Operation.JSON.t()
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
  Associates the list of tags in the input tags parameter with the resource identified by the
  resource_arn input parameter

  ## Examples

      iex> resource_arn = "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
      iex> tags = [%{key: "Name", value: "testName"}, %{key: "Type", value: "testType"}]
      iex> ExAws.CodeDeploy.tag_resource(resource_arn, tags)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "Tags" => [
            %{"Key" => "Name", "Value" => "testName"},
            %{"Key" => "Type", "Value" => "testType"}
          ],
          "resourceArn" => "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.TagResource"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec tag_resource(resource_arn(), tags()) :: ExAws.Operation.JSON.t()
  def tag_resource(resource_arn, tags) when is_list(tags) do
    camelize_rules = Map.put(Utils.camelize_rules(), :keys, %{tags: :upper})

    %{resource_arn: resource_arn, tags: tags}
    |> Utils.camelize_map(camelize_rules)
    |> request(:tag_resource)
  end

  @doc """
  Disassociates a resource from a list of tags. The resource is identified by the resource_arn input
  parameter. The tags are identified by the list of keys in the tag_keys input parameter

  ## Example

      iex> resource_arn = "arn:aws:codedeploy:us-west-2:111122223333:application:testApp"
      iex> tag_keys = ["key1", "key2"]
      iex> ExAws.CodeDeploy.untag_resource(resource_arn, tag_keys)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "ResourceArn" => "arn:aws:codedeploy:us-west-2:111122223333:application:testApp",
          "TagKeys" => [["key1", "key2"]]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.UntagResource"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec untag_resource(resource_arn(), [binary()]) :: ExAws.Operation.JSON.t()
  def untag_resource(resource_arn, tag_keys) do
    %{"ResourceArn" => resource_arn, "TagKeys" => [tag_keys]}
    |> request(:untag_resource)
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
  Registers with AWS CodeDeploy a revision for the specified application

  ## Examples

      iex> application_name = "WordPress_App"
      iex> revision_location = %{s3_location: %{bucket: "CodeDeployDemoBucket", key: "RevisedWordPressApp.zip", bundle_type: "zip", e_tag: "cecc9b8a08eac650a6e71fdb88EXAMPLE"}}
      iex> opts = %{description: "Revised WordPress application"}
      iex> ExAws.CodeDeploy.register_application_revision(application_name, revision_location, opts)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "WordPress_App",
          "description" => "Revised WordPress application",
          "revisionLocation" => %{
            "s3Location" => %{
              "bucket" => "CodeDeployDemoBucket",
              "bundleType" => "zip",
              "eTag" => "cecc9b8a08eac650a6e71fdb88EXAMPLE",
              "key" => "RevisedWordPressApp.zip"
            }
          }
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.RegisterApplicationRevision"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec register_application_revision(
          application_name(),
          revision_location(),
          register_application_revision_optional_details()
        ) ::
          ExAws.Operation.JSON.t()
  def register_application_revision(application_name, revision_location, opts \\ %{}) do
    opts
    |> Map.merge(%{application_name: application_name, revision_location: revision_location})
    |> Utils.camelize_map()
    |> request(:register_application_revision)
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
  @spec register_on_premises_instance(instance_name(), register_on_premises_instance_optional_details()) ::
          ExAws.Operation.JSON.t()
  def register_on_premises_instance(instance_name, opts \\ []) do
    opts
    |> Utils.keyword_to_map()
    |> Utils.camelize_map()
    |> Map.merge(%{"instanceName" => instance_name})
    |> request(:register_on_premises_instance)
  end

  @doc """
  Removes one or more tags from one or more on-premises instances

  ## Examples

      iex> instance_names = ["AssetTag12010298EX", "AssetTag23121309EX"]
      iex> tags = [%{key: "Name", value: "CodeDeployDemo-OnPrem"}]
      iex> ExAws.CodeDeploy.remove_tags_from_on_premises_instances(instance_names, tags)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "instanceNames" => ["AssetTag12010298EX", "AssetTag23121309EX"],
          "tags" => [%{"Key" => "Name", "Value" => "CodeDeployDemo-OnPrem"}]
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.RemoveTagsFromOnPremisesInstances"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec remove_tags_from_on_premises_instances([instance_name()], tags()) :: ExAws.Operation.JSON.t()
  def remove_tags_from_on_premises_instances(instance_names, tags) when is_list(instance_names) and is_list(tags) do
    %{instance_names: instance_names, tags: tags}
    |> Utils.camelize_map()
    |> request(:remove_tags_from_on_premises_instances)
  end

  @doc """
  In a blue/green deployment, overrides any specified wait time and starts terminating instances
  immediately after the traffic routing is complete

  ## Examples

      iex> ExAws.CodeDeploy.skip_wait_time_for_instance_termination("d-UBCT41FSL")
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{"deploymentId" => "d-UBCT41FSL"},
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.SkipWaitTimeForInstanceTermination"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec skip_wait_time_for_instance_termination(deployment_id()) :: ExAws.Operation.JSON.t()
  def skip_wait_time_for_instance_termination(deployment_id) do
    %{"deploymentId" => deployment_id}
    |> request(:skip_wait_time_for_instance_termination)
  end

  @doc """
  Changes the name of an application.
  """
  @spec update_application(application_name(), application_name()) :: ExAws.Operation.JSON.t()
  def update_application(application_name, new_application_name) do
    %{"applicationName" => application_name, "newApplicationName" => new_application_name}
    |> request(:update_application)
  end

  @doc """
  Changes information about a deployment group. See `create_deployment_group/4`

  If you do not want to change the service_role_arn pass nil. This will exclude that data from the
  API call. Passing the current service_role_arn works as well.

  ## Examples

      iex> application_name = "WordPress_App"
      iex> deployment_group_name = "WordPress_DG"
      iex> service_role_arn = "arn:aws:iam::123456789012:role/CodeDeployDemoRole"
      iex> deployment_group_details = %{
      ...>   auto_scaling_groups: ["CodeDeployDemo-ASG"],
      ...>   deployment_config_name: "CodeDeployDefault.OneAtATime",
      ...>   ec2_tag_filters: [%{key: "Name", value: "CodeDeployDemo", type: "KEY_AND_VALUE"}]
      ...> }
      iex> ExAws.CodeDeploy.update_deployment_group(application_name, deployment_group_name, service_role_arn, deployment_group_details)
      %ExAws.Operation.JSON{
        stream_builder: nil,
        http_method: :post,
        parser: &Function.identity/1,
        error_parser: &Function.identity/1,
        path: "/",
        data: %{
          "applicationName" => "WordPress_App",
          "autoScalingGroups" => ["CodeDeployDemo-ASG"],
          "currentDeploymentGroupName" => "WordPress_DG",
          "deploymentConfigName" => "CodeDeployDefault.OneAtATime",
          "ec2TagFilters" => [
            %{"Key" => "Name", "Type" => "KEY_AND_VALUE", "Value" => "CodeDeployDemo"}
          ],
          "serviceRoleArn" => "arn:aws:iam::123456789012:role/CodeDeployDemoRole"
        },
        params: %{},
        headers: [
          {"x-amz-target", "CodeDeploy_20141006.UpdateDeploymentGroup"},
          {"content-type", "application/x-amz-json-1.1"}
        ],
        service: :codedeploy,
        before_request: nil
      }
  """
  @spec update_deployment_group(
          application_name(),
          deployment_group_name(),
          service_role_arn() | nil,
          deployment_group_optional_details()
        ) :: ExAws.Operation.JSON.t()
  def update_deployment_group(
        application_name,
        current_deployment_group_name,
        service_role_arn \\ nil,
        deployment_group_details \\ %{}
      ) do
    case service_role_arn do
      nil ->
        %{}

      _ ->
        %{service_role_arn: service_role_arn}
    end
    |> Map.merge(%{application_name: application_name, current_deployment_group_name: current_deployment_group_name})
    |> Map.merge(deployment_group_details)
    |> Utils.camelize_map()
    |> request(:update_deployment_group)
  end

  ####################
  # Helper Functions #
  ####################
  defp add_auto_rollback(acc, auto_rollback) when is_boolean(auto_rollback) do
    Map.put(acc, "autoRollbackEnabled", auto_rollback)
  end

  defp add_auto_rollback(acc, _), do: acc

  defp request(data, action, opts \\ %{}) do
    operation = Utils.camelize(action, %{default: :upper})

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
