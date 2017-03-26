defmodule ClientsManager.Forwarder do
  @moduledoc """
  Provides function for forwarding messages
  """

  alias ClientsManager.Client.Client
  alias ClientsManager.Client.Manager
  alias ClientsManager.Table

  @doc """
  Forwards message to all clients except passed client_id
  """
  @spec forward_from(integer, String.t) :: none
  def forward_from(client_id, message) do
    Table.each(:clients,
      fn
        (id, {client}) when id != client_id ->
          if Client.found?(client) do
            Table.update(:clients, client_id, {Manager.send!(client, message)})
          end
        (_, _) -> nil
      end
    )
  end
end
