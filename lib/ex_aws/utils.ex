defmodule ExAws.CodeDeploy.Utils do
  @moduledoc """
  Helper utility functions
  """

  # There are lists that can appear in a Map where the list elements
  # are Maps and we want to handle capitalization differently. For example,
  # "ec2TagFilters" is a list where the allowed keys ("Key", "Value" and
  # "Type") should all use :upper).
  @special_capitalize_keys %{
    "ec2TagFilters" => :upper,
    "tagFilters" => :upper,
    "tags" => :upper,
    "onPremisesInstanceTagFilters" => :upper,
    "ec2TagSet" => :upper,
    target_status: :upper,
    service_instance_label: :upper
  }

  @spec camelize(atom() | binary(), any()) :: binary()
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
  def camelize(val, first_word_capitalization \\ :lower)

  def camelize(val, first_word_capitalization) when is_atom(val) do
    val |> to_string() |> camelize(first_word_capitalization)
  end

  def camelize(val, first_word_capitalization) when is_binary(val) do
    ~r/(?:^|[-_])|(?=[A-Z])/
    |> Regex.split(val, trim: true)
    |> camelize_list(first_word_capitalization)
    |> Enum.join()
  end

  @doc """
  Camelize Map keys, including traversing values that are also Maps.

  The caller can pass in an argument to indicate whether the first letter of a key for the map are
  downcased or capitalized.

  Keys should be atoms or strings and follow the rules listed for the `camelize/2` function.

  ## Example

      iex> val = %{abc_def: 123, another_val: "val2"}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => "val2"}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val)
      %{"abcDef" => 123, "anotherVal" => %{"embedValue" => "val2"}}

      iex> val = %{abc_def: 123, another_val: %{embed_value: "val2"}}
      iex> ExAws.CodeDeploy.Utils.camelize_map(val, :upper)
      %{"AbcDef" => 123, "AnotherVal" => %{"EmbedValue" => "val2"}}
  """
  def camelize_map(val, first_word_capitalization \\ :lower)

  def camelize_map(a_map, first_word_capitalization) when is_map(a_map) do
    for {key, val} <- a_map, into: %{} do
      camelized_key = camelize(key, Map.get(@special_capitalize_keys, key, first_word_capitalization))
      value_capitalization = Map.get(@special_capitalize_keys, camelized_key, first_word_capitalization)
      {camelized_key, camelize_map(val, value_capitalization)}
    end
  end

  def camelize_map(a_list, first_word_capitalization) when is_list(a_list) do
    Enum.map(a_list, &camelize_map(&1, first_word_capitalization))
  end

  def camelize_map(val, _first_word_capitalization), do: val

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
  Camelize a list

  The caller can pass in an argument to indicate whether the first letter of the first element in
  the list is downcased or capitalized. The remainder elements are always capitalized.

  ## Examples

      iex> ExAws.CodeDeploy.Utils.camelize_list([], :lower)
      []

      iex> ExAws.CodeDeploy.Utils.camelize_list(["a", "cat"], :lower)
      ["a", "Cat"]

      iex> ExAws.CodeDeploy.Utils.camelize_list(["a", "cat"], :upper)
      ["A", "Cat"]
  """
  def camelize_list(val, first_word_capitalization \\ :lower)
  def camelize_list([], _), do: []

  def camelize_list([h | t], :lower) do
    [String.downcase(h)] ++ camelize_list(t, :upper)
  end

  def camelize_list([h | t], :upper) do
    [String.capitalize(h)] ++ camelize_list(t, :upper)
  end

  @doc """
  Handle building a nextToken element for paging

  ## Examples

      iex> ExAws.CodeDeploy.Utils.build_paging([])
      %{}

      iex> ExAws.CodeDeploy.Utils.build_paging([{:next_token, "123"}])
      %{"nextToken" => "123"}

      iex> ExAws.CodeDeploy.Utils.build_paging({:next_token, "123"})
      %{"nextToken" => "123"}

      iex> ExAws.CodeDeploy.Utils.build_paging(%{next_token: "123"})
      %{"nextToken" => "123"}
  """
  def build_paging(opts) when is_list(opts) do
    case Keyword.get(opts, :next_token) do
      val when is_binary(val) -> %{"nextToken" => val}
      _ -> %{}
    end
  end

  def build_paging(opts) when is_map(opts) do
    camelize_map(opts)
  end

  def build_paging(opts) do
    build_paging([opts])
  end

  @doc """
  Take a list of tag and convert it into a format suitable for
  API.

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
end
