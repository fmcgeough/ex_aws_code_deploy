defmodule ExAws.CodeDeploy.Utils do
  @moduledoc """
  Helper utility functions
  """

  # There are keys that are encountered that have special rules for capitalizing
  # for subkeys found in them.
  @camelize_subkeys %{
    ec2_tag_filters: %{key: :upper, type: :upper, value: :upper},
    tag_filters: %{key: :upper, type: :upper, value: :upper},
    tags: %{key: :upper, value: :upper},
    on_premises_instance_tag_filters: %{key: :upper, type: :upper, value: :upper},
    ec2_tag_set: %{key: :upper, type: :upper, value: :upper},
    target_filters: %{target_status: :upper, service_instance_label: :upper}
  }
  @camelize_rules %{subkeys: @camelize_subkeys, default: :lower, keys: %{}}

  @typedoc """
  The camelize, camelize_list, and camelize_map take an argument that is
  a data structure providing rules for capitalization.

  - subkeys - this provides a map that indicates how keys found under this
    particular key should be camelized
  - keys - this provides a map that indicate how particular keys should be
    camelized
  - default - indicates whether `:upper` or `:lower` is used by default
  """
  @type camelize_rules() :: %{
          optional(:subkeys) => map(),
          optional(:keys) => map(),
          required(:default) => :upper | :lower
        }

  @doc """
  Return the default camelize rules

  A caller can override this by creating a `t:camelize_rules/0` and passing
  it into functions instead of the default.
  """
  @spec camelize_rules() :: camelize_rules()
  def camelize_rules, do: @camelize_rules

  @spec camelize(atom() | binary(), camelize_rules()) :: binary()
  @doc """
  Camelize an atom or string value

  This works as expected if the val uses an underscore or
  hyphen to separate words. This only works for atoms and
  strings. Passing another value type (integer, list, map)
  will raise exception.

  ## Example

      iex> ExAws.CodeDeploy.Utils.camelize(:test_val)
      "testVal"

      iex> ExAws.CodeDeploy.Utils.camelize("test_val")
      "testVal"

      iex> ExAws.CodeDeploy.Utils.camelize("abc-def-a123")
      "abcDefA123"

      iex> ExAws.CodeDeploy.Utils.camelize(:A_test_of_initial_cap)
      "aTestOfInitialCap"
  """
  def camelize(val, camelize_rules \\ @camelize_rules)

  def camelize(val, camelize_rules) when is_atom(val) do
    camelization = camelization_for_val(val, camelize_rules)
    val |> to_string() |> camelize(%{camelize_rules | default: camelization})
  end

  def camelize(val, camelize_rules) when is_binary(val) do
    ~r/(?:^|[-_])|(?=[A-Z])/
    |> Regex.split(val, trim: true)
    |> camelize_split_string(camelize_rules.default)
    |> Enum.join()
  end

  @doc """
  Camelize Map keys, including traversing values that are also Maps.

  The caller can pass in an argument to indicate whether the first letter of a key for the map are
  downcased or capitalized.

  Keys should be atoms and follow the rules listed for the `camelize/2` function.

  ## Example

      iex> val = %{abc_def: 123, another_val: "val2"}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => "val2"}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => %{"embedValue" => "val2"}}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val, %{subkeys: %{}, keys: %{}, default: :upper})
      %{"AbcDef" => 123, "AnotherVal" => %{"EmbedValue" => "val2"}}
  """
  def camelize_map(val, camelize_rules \\ @camelize_rules)

  def camelize_map(a_map, camelize_rules) when is_map(a_map) do
    for {key, val} <- a_map, into: %{} do
      camelized_key = camelize(key, camelize_rules)
      subkey_capitalization = Map.get(camelize_rules.subkeys, key, camelize_rules.keys)
      {camelized_key, camelize_map(val, %{camelize_rules | keys: subkey_capitalization})}
    end
  end

  def camelize_map(a_list, camelize_rules) when is_list(a_list) do
    Enum.map(a_list, &camelize_map(&1, camelize_rules))
  end

  def camelize_map(val, _camelize_rules), do: val

  @doc """
  If val is a Keyword then convert to a Map, else
  return val

  ## Examples

      iex> ExAws.CodeDeploy.Utils.keyword_to_map([{:a, 7}, {:b, "abc"}])
      %{a: 7, b: "abc"}

      iex> ExAws.CodeDeploy.Utils.keyword_to_map(%{a: 7, b: %{c: "abc"}})
      %{a: 7, b: %{c: "abc"}}

      iex> ExAws.CodeDeploy.Utils.keyword_to_map([1, 2, 3])
      [1, 2, 3]
  """
  def keyword_to_map(val) do
    case Keyword.keyword?(val) do
      true -> Enum.map(val, & &1) |> Map.new()
      false -> val
    end
  end

  @doc """
  Take the various forms of allowed paging options and create a
  `%{next_token: val}`

  ## Examples

      # Passing an unexpected value (no paging found) returns an empty map
      iex> ExAws.CodeDeploy.Utils.normalize_paging([])
      %{}

      # Different approaches to defining Keyword list work
      iex> ExAws.CodeDeploy.Utils.normalize_paging([{:next_token, "123"}])
      %{next_token: "123"}

      iex> ExAws.CodeDeploy.Utils.normalize_paging([next_token: "123"])
      %{next_token: "123"}

      # Pass a tuple, no list
      iex> ExAws.CodeDeploy.Utils.normalize_paging({:next_token, "123"})
      %{next_token: "123"}

      # Pass in data already formatted, returns the same data
      iex> ExAws.CodeDeploy.Utils.normalize_paging(%{next_token: "123"})
      %{next_token:  "123"}
  """
  def normalize_paging(opts) when is_list(opts) do
    case Keyword.get(opts, :next_token) do
      val when is_binary(val) -> %{next_token: val}
      _ -> %{}
    end
  end

  def normalize_paging({:next_token, val}) do
    %{next_token: val}
  end

  def normalize_paging(%{next_token: _val} = paging) do
    paging
  end

  def normalize_paging(_val), do: %{}

  @doc """
  Take a list of tag and convert it into a list where each elemet
  is a map with atom keys.

  ## Examples

      iex> ExAws.CodeDeploy.Utils.normalize_tags([])
      []

      iex> ExAws.CodeDeploy.Utils.normalize_tags([{"my_key", "value1"}])
      [%{key: "my_key", value: "value1"}]
  """
  def normalize_tags(tags) when is_list(tags) do
    do_normalize_tags(tags, [])
  end

  def normalize_tags(_tags), do: []

  defp do_normalize_tags([], acc), do: Enum.reverse(acc)

  defp do_normalize_tags([h | t], acc) do
    if is_map(h) do
      do_normalize_tags(t, [h | acc])
    else
      case h do
        {key_name, value} -> do_normalize_tags(t, [%{key: key_name, value: value} | acc])
        _ -> do_normalize_tags(t, acc)
      end
    end
  end

  defp camelization_for_val(val, %{keys: keys, default: default}) do
    Map.get(keys, val, default)
  end

  defp camelization_for_val(_val, %{default: default}), do: default

  # Camelize a word that has been split into parts
  #
  # The caller can pass in an argument to indicate whether the first letter of the first element in
  # the list is downcased or capitalized. The remainder elements are always capitalized.
  #
  # ## Examples
  #
  #     iex> ExAws.CodeDeploy.Utils.camelize_split_string([], :lower)
  #     []
  #
  #     iex> ExAws.CodeDeploy.Utils.camelize_split_string(["a", "cat"], :lower)
  #     ["a", "Cat"]
  #
  #     iex> ExAws.CodeDeploy.Utils.camelize_split_string(["a", "cat"], :upper)
  #     ["A", "Cat"]
  defp camelize_split_string([], _), do: []

  defp camelize_split_string([h | t], :lower) do
    [String.downcase(h)] ++ camelize_split_string(t, :upper)
  end

  defp camelize_split_string([h | t], :upper) do
    [String.capitalize(h)] ++ camelize_split_string(t, :upper)
  end
end
