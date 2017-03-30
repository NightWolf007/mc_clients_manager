defmodule ClientsManager do
  @moduledoc """
  Provides public functions for managing clients
  """

  @type client_type :: :nekto
  @type client_id :: integer

  alias ClientsManager.Table
  alias ClientsManager.Client.Manager
  alias ClientsManager.Client.Client

  @doc """
  Creates new client
  """
  @spec create(pid, client_type) :: {:ok, client_id}
  def create(supervisor, type) do
    client_id = Table.insert(:clients, {Manager.new(type)})
    ClientsManager.Supervisor.start_client(supervisor, client_id)
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
  @spec send(client_id, String.t) :: :ok | :error
  def send(client_id, message) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} ->
        Table.update(:clients, client_id, {Manager.send!(client, message)})
        :ok
      _ ->
        :error
    end
  end

  @doc """
  Sends message to all clients except the clients in list
  """
  @spec send_broadcast(Stringt.t, list(client_id)) :: :ok
  def send_broadcast(message, excepted \\ []) do
    Table.each(:clients,
      fn
        (id, {client}) ->
          if !Enum.member?(excepted, id) && Client.found?(client) do
            Table.update(:clients, id, {Manager.send!(client, message)})
          end
      end
    )
    :ok
  end

  @doc """
  Returns all clients
  """
  @spec clients() :: list({client_id, %ClientsManager.Client.Client{}})
  def clients do
    Table.map(:clients, fn(id, {client}) -> {id, client} end)
  end

  @doc """
  Returns client by id
  """
  @spec client(client_id) :: %ClientsManager.Client.Client{}
  def client(client_id) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} -> {:ok, client}
      _ -> {:error}
    end
  end

  @doc """
  Reconnects clients
  """
  @spec reconnect(pid, client_id) :: :ok | :error
  def reconnect(supervisor, client_id) do
    case Table.find(:clients, client_id) do
      {:ok, {_client}} ->
        ClientsManager.Supervisor.stop_client(supervisor, client_id)
        ClientsManager.Supervisor.start_client(supervisor, client_id)
        :ok
      _ ->
        :error
    end
  end

  @doc """
  Mutes client
  """
  @spec mute(client_id) :: :ok | :error
  def mute(client_id) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} ->
        Table.update(:clients, client_id, {Manager.mute(client)})
        :ok
      _ ->
        :error
    end
  end

  @doc """
  Unmutes client
  """
  @spec unmute(client_id) :: :ok | :error
  def unmute(client_id) do
    case Table.find(:clients, client_id) do
      {:ok, {client}} ->
        Table.update(:clients, client_id, {Manager.unmute(client)})
        :ok
      _ ->
        :error
    end
  end
end
