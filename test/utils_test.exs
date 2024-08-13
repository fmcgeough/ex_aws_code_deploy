defmodule ExAws.CodeDeploy.UtilsTest do
  @moduledoc false
  use ExUnit.Case

  doctest ExAws.CodeDeploy.Utils
  alias ExAws.CodeDeploy.Utils

  @revision_type %{
    revision_type: "abc",
    s3_location: %{
      bucket: "testBucket",
      bundle_type: "tar",
      e_tag: "etag",
      key: "key",
      version: "v1234"
    },
    git_hub_location: %{
      repository: "TestOrg/TestRepo",
      commit_id: "someSha"
    },
    app_spec_content: %{
      sha256: "c99558bfe6446fb721075d1e2df22f575fc90557af7874ed9756d05a615b9482",
      content: "test"
    }
  }

  @expected_revision_type %{
    "appSpecContent" => %{
      "content" => "test",
      "sha256" => "c99558bfe6446fb721075d1e2df22f575fc90557af7874ed9756d05a615b9482"
    },
    "gitHubLocation" => %{
      "commitId" => "someSha",
      "repository" => "TestOrg/TestRepo"
    },
    "revisionType" => "abc",
    "s3Location" => %{
      "bucket" => "testBucket",
      "bundleType" => "tar",
      "eTag" => "etag",
      "key" => "key",
      "version" => "v1234"
    }
  }

  @create_deployment_input %{
    deployment_group_name: "depGroupName",
    revision: @revision_type
  }

  @expected_create_deployment %{
    "deploymentGroupName" => "depGroupName",
    "revision" => @expected_revision_type
  }

  describe "camelize/1" do
    test "camelize atom" do
      assert "test" == Utils.camelize(:test)
      assert "anAtom" == Utils.camelize(:an_atom)
      assert "aMoreComplexAtom123" == Utils.camelize(:a_more_complex_atom123)
      refute "willNotMatch" == Utils.camelize(:will_nOt_match)
    end

    test "camelize string" do
      assert "test" == Utils.camelize("test")
      assert "anAtom" == Utils.camelize("an_atom")
      assert "noChangeNeeded" == Utils.camelize("noChangeNeeded")
    end
  end

  describe "camelize_map/1" do
    test "simple one-level map" do
      a_map = %{abc: "val1", another_val: "val2"}
      assert %{"abc" => "val1", "anotherVal" => "val2"} == Utils.camelize_map(a_map)
    end

    test "2-level map" do
      assert @expected_revision_type == Utils.camelize_map(@revision_type)
    end

    test "3-level map" do
      assert @expected_create_deployment == Utils.camelize_map(@create_deployment_input)
    end
  end

  # the library accepts a variety of input for paging argument
  describe "build_paging/1" do
    test "empty list" do
      assert %{} == Utils.build_paging([])
    end

    test "keyword" do
      assert %{"nextToken" => "test"} = Utils.build_paging([{:next_token, "test"}])
    end

    test "map" do
      assert %{"nextToken" => "test"} = Utils.build_paging(%{next_token: "test"})
    end

    test "raw tuple" do
      assert %{"nextToken" => "test"} = Utils.build_paging({:next_token, "test"})
    end
  end

  describe "keyword_to_map/1" do
    test "keyword is converted to map" do
      assert %{a: 123, b: 456} == Utils.keyword_to_map(a: 123, b: 456)
    end

    test "not a keyword, return the original value" do
      assert "abc" == Utils.keyword_to_map("abc")
      assert {:test, 1} == Utils.keyword_to_map({:test, 1})
      assert %{a: %{b: 12}, c: 5} == Utils.keyword_to_map(%{a: %{b: 12}, c: 5})
    end
  end

  describe "normalize_tags/1" do
    test "no tags gives empty list" do
      assert [] == Utils.normalize_tags([])
    end

    test "single valid tag works" do
      expected_val = [%{key: "my_key", value: "my_value"}]
      assert expected_val == Utils.normalize_tags([{"my_key", "my_value"}])
    end

    test "multiple valid tags works" do
      expected_val = [%{key: "my_key", value: "my_value"}, %{key: "my_key2", value: "my_value2"}]
      assert expected_val == Utils.normalize_tags([{"my_key", "my_value"}, {"my_key2", "my_value2"}])
    end

    test "invalid tags are skipped" do
      expected_val = [%{key: "my_key", value: "my_value"}, %{key: "my_key2", value: "my_value2"}]
      assert expected_val == Utils.normalize_tags([{"my_key", "my_value"}, {}, {"my_key2", "my_value2"}])
    end
  end
end
