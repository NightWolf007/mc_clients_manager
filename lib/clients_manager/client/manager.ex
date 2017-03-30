defmodule ClientsManager.Client.Manager do
  @moduledoc """
  Provides abstract functions for client's managers
  """

  @type type :: :nekto

  alias ClientsManager.Client.Client

  @doc """
  Initializes client
  """
  def new(type) do
    %Client{type: type}
  end

  @doc """
  Provides actions for client connection
  Returns client
  """
  @spec connect!(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def connect!(%{type: type} = client) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).connect!)
  end

  @doc """
  Provides actions for prepare client
  Returns updated client
  """
  @spec prepare!(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def prepare!(%{data: data, type: type} = client) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).prepare!(data))
  end

  @doc """
  Starts search
  Returns updated client
  """
  @spec search!(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def search!(%{data: data, type: type} = client) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).search!(data))
  end

  @doc """
  Sends message
  Returns updated client
  """
  @spec send!(%ClientsManager.Client.Client{}, String.t) ::
        %ClientsManager.Client.Client{}
  def send!(%{data: data, type: type} = client, message) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).send!(data, message))
  end

  @doc """
  Leaves dialog
  Returns updated client
  """
  @spec leave!(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def leave!(%{data: data, type: type} = client) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).leave!(data))
  end

  @doc """
  Provides actions for closing connection
  Returns updated client
  """
  @spec disconnect!(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def disconnect!(%{data: data, type: type} = client) do
    client
    |> Map.put(:data, Client.which_module(type, Manager).disconnect!(data))
  end

  @doc """
  Provides actions for starting listenning loop
  """
  @spec listen!(%ClientsManager.Client.Client{}, pid) :: none
  def listen!(%{data: data, type: type}, gen_event) do
    Client.which_module(type, Manager).listen!(data, gen_event)
  end

  @doc """
  Mutes client
  """
  @spec mute(%ClientsManager.Client.Client{}) :: %ClientsManager.Client.Client{}
  def mute(client) do
    client |> Map.put(:muted, true)
  end

  @doc """
  Unmutes client
  """
  @spec unmute(%ClientsManager.Client.Client{}) ::
        %ClientsManager.Client.Client{}
  def unmute(client) do
    client |> Map.put(:muted, false)
  end
end
