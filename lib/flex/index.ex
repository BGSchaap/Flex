defmodule Flex.Index do
  @moduledoc """
  This module provides an interface for working with indexes
  """
  alias Flex.API
  
  def analyze(index, analyzer, text), do: [index, "_analyze"] |> make_path |> API.post(%{analyzer: analyzer, text: text})
  
  def search(index, query), do: [index, "_search"] |> make_path |> API.post(%{query: query})
  
  def all(index), do: [index, "_search"] |> make_path |> API.post(%{query: %{match_all: %{}}})

  @doc """
  Get information about an index

  ## Examples

      iex> Flex.Index.info "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Flex.Index.create "elastic_test_index"
      ...> {:ok, %{"elastic_test_index" => info}} = Flex.Index.info "elastic_test_index"
      ...> with %{"aliases" => _, "mappings" => _, "settings" => _} <- info, do: :passed
      :passed
  """
  def info(index), do: index |> make_path |> API.get

  @doc """
  Create a new index

  ## Examples

     iex> Flex.Index.create "elastic_test_index"
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
     iex> Flex.Index.create "elastic_test_index"
     {:error, :index_already_exists_exception}

     iex> Flex.Index.create "elastic_test_index", %{settings: %{number_of_shards: 3}}
     {:ok, %{"acknowledged" => true, "shards_acknowledged" => true}}
  """
  def create(index, options \\ %{}) do
    index |> make_path |> API.put(options)
  end

  @doc """
  Checks if an index exists

  ## Examples

      iex> Flex.Index.exists? "elastic_test_index"
      {:ok, false}

      iex> Flex.Index.create "elastic_test_index"
      ...> Flex.Index.exists? "elastic_test_index"
      {:ok, true}
  """
  def exists?(index) do
    with {:ok, _} <- index |> make_path |> API.head
    do
      {:ok, true}
    else
      {:error, :not_found} -> {:ok, false}
      err -> err
    end
  end

  @doc """
  Deletes an index

  ## Examples

      iex> Flex.Index.delete "elastic_test_index"
      {:error, :index_not_found_exception}

      iex> Flex.Index.create "elastic_test_index"
      ...> Flex.Index.delete "elastic_test_index"
      {:ok, %{"acknowledged" => true}}
  """
  def delete(index) do
    index |> make_path |> API.delete
  end
  
  def delete_all, do: delete "*"
  
  def refresh(index), do: [index, "_refresh"] |> make_path() |> API.post()

  @doc false
  defp make_path(parts) when is_list(parts), do: "/" <> Enum.join(parts, "/")
  defp make_path(part), do: make_path([part])
end