defmodule ClientsManager.Table do
  @moduledoc """
  Module wrapper for ets table
  """

  @type t :: integer

  @doc """
  Creates table with name
  Returns table
  """
  @spec create(Atom.t, list(Atom.t)) :: t
  def create(name, options) do
    table = :ets.new(name, [:ordered_set | options])
    :ets.insert_new(table, {:system, 0})
    table
  end

  @doc """
  Inserts new record in table
  Returns id
  """
  @spec insert(t, Tuple.t) :: integer
  def insert(table, data) do
    id = next_id(table)
    :ets.insert_new(table, Tuple.insert_at(data, 0, id))
    id
  end

  @doc """
  Finds row by id
  Returns :ok with data or :error if id not found
  """
  @spec find(t, integer) :: {:ok, Tuple.t} | :error
  def find(table, id) do
    case :ets.lookup(table, id) do
      [row] -> {:ok, Tuple.delete_at(row, 0)}
      [] -> :error
    end
  end

  @doc """
  Updates data in row
  Returns :ok with new data or :error if id not found
  """
  @spec update(t, integer, Tuple.t) :: {:ok, Tuple.t} | :error
  def update(table, id, data) do
    case find(table, id) do
      {:ok, _} ->
        :ets.insert(table, Tuple.insert_at(data, 0, id))
        {:ok, data}
      _ ->
        :error
    end
  end

  @doc """
  Deletes row by id
  Returns :ok with old data or :error if id not found
  """
  @spec delete(t, integer) :: {:ok, Tuple.t} | :error
  def delete(table, id) do
    case find(table, id) do
      {:ok, data} ->
        :ets.delete(table, id)
        {:ok, data}
      _ ->
        :error
    end
  end

  @doc """
  Destroys table
  """
  @spec destroy(t) :: :ok | :error
  def destroy(table) do
    if :ets.delete(table), do: :ok, else: :error
  end

  @doc """
  Iterates each row in table with given function
  """
  @spec each(t, (integer, Tuple.t -> any)) :: none
  def each(table, fun) do
    :ets.foldl(
      fn(row, _) ->
        id = elem(row, 0)
        if id != :system, do: fun.(id, Tuple.delete_at(row, 0))
      end,
      nil,
      table
    )
  end

  defp next_id(table) do
    :ets.update_counter(table, :system, 1)
  end
end
