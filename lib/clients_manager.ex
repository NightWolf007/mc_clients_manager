defmodule ClientsManager do
  @moduledoc """
  Provides public functions for managing clients
  """

  @type client_type :: :nekto
  @type client_id :: integer

  alias ClientsManager.Table
  alias ClientsManager.Client.Manager

  @doc """
  Creates new client
  """
  @spec create(pid, client_type) :: {:ok, client_id}
  def create(supervisor, type) do
    client = Manager.connect!(type)
    client_id = Table.insert(:clients, {client})
    ClientsManager.Supervisor.start_client(supervisor, client_id)
    Table.update(:clients, client_id, {Manager.prepare!(client)})
    {:ok, client_id}
  end

  @doc """
  Removes client
  """
  @spec remove(pid, client_id) :: :ok | :error
  def remove(supervisor, client_id) do
    case Table.delete(:clients, client_id) do
      {:ok, {_client}} ->
        ClientsManager.Supervisor.stop_client(supervisor, client_id)
        :ok
      _ ->
        :error
    end
  end

  @doc """
  Starts searching for client
  """
  @spec search(client_id) :: :ok | :error
  def search(client_id) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} ->
        Table.update(:clients, client_id, {Manager.search!(client)})
        :ok
      _ ->
        :error
    end
  end

  @doc """
  Sends message to client
  """
  @spec send(client_id, String.t) :: :ok
  def send(client_id, message) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} ->
        Table.update(:clients, client_id, {Manager.send!(client, message)})
        :ok
      _ ->
        :error
    end
  end
end
