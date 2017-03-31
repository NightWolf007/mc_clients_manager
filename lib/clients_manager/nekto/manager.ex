defmodule ClientsManager.Nekto.Manager do
  @moduledoc """
  Provides functions for managing nekto client
  """

  alias NektoClient.WebSocket.Sender
  alias NektoClient.WebSocket.Receiver
  alias NektoClient.Model.SearchOptions
  alias ClientsManager.Nekto.Client

  @doc """
  Provides actions for client connection
  Returns client
  """
  @spec connect! :: %ClientsManager.Nekto.Client{}
  def connect! do
    socket = NektoClient.connect!
    %Client{socket: socket}
  end

  @doc """
  Provides actions for prepare client
  Returns updated client
  """
  @spec prepare!(%ClientsManager.Nekto.Client{}) ::
        %ClientsManager.Nekto.Client{}
  def prepare!(%{socket: socket} = client) do
    token = NektoClient.chat_token!
    Sender.auth!(socket, token)
    Map.merge(client, %{token: token, search_options: nil})
  end

  @doc """
  Starts search
  Returns updated client
  """
  @spec search!(%ClientsManager.Nekto.Client{}, Map.t) ::
        %ClientsManager.Nekto.Client{}
  def search!(%{socket: socket} = client, options) do
    search_options = SearchOptions.new(options)
    Sender.search_company!(socket, search_options)
    Map.put(client, :search_options, search_options)
  end

  @doc """
  Sends message
  Returns updated client
  """
  @spec send!(%ClientsManager.Nekto.Client{}, String.t) ::
        %ClientsManager.Nekto.Client{}
  def send!(%{socket: socket, dialog: %{id: dialog_id}} = client, message) do
    Sender.chat_message!(socket, dialog_id,
                         Client.request_id(client), message)
    Client.inc_request_counter(client)
  end

  @doc """
  Leaves dialog
  Returns updated client
  """
  @spec leave!(%ClientsManager.Nekto.Client{}) :: %ClientsManager.Nekto.Client{}
  def leave!(%{socket: socket, dialog: %{id: dialog_id}} = client) do
    Sender.leave_dialog!(socket, dialog_id)
    client
  end

  @doc """
  Provides actions for closing connection
  Returns updated client
  """
  @spec disconnect!(%ClientsManager.Nekto.Client{}) ::
        %ClientsManager.Nekto.Client{}
  def disconnect!(%{socket: socket} = client) do
    NektoClient.disconnect(socket)
    Map.put(client, :socket, nil)
  end

  @doc """
  Provides actions for starting listenning loop
  """
  @spec listen!(%ClientsManager.Nekto.Client{}, pid) :: none
  def listen!(%{socket: socket}, gen_event) do
    Receiver.listen(socket, gen_event)
  end
end
