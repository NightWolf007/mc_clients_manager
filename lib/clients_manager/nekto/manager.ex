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
  def prepare!(%{socket: socket}) do
    token = NektoClient.chat_token!
    Sender.auth!(socket, token)
    %Client{
      socket: socket,
      token: token,
      search_options: default_search_options()
    }
  end

  @doc """
  Starts search
  Returns updated client
  """
  @spec search!(%ClientsManager.Nekto.Client{}) ::
        %ClientsManager.Nekto.Client{}
  def search!(%{socket: socket, search_options: search_options} = client) do
    Sender.search_company!(socket, search_options)
    client
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

  defp default_search_options do
    %SearchOptions{
      my_sex: "W",
      wish_sex: "M",
      my_age_from: 18,
      my_age_to: 21,
      wish_age: ["0t17", "18t21", "22t25", "25t35", "36t100"]
    }
  end
end
