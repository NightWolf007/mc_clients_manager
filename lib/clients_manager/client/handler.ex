defmodule ClientsManager.Client.Handler do
  @moduledoc """
  Provides gen event handlers
  """

  use GenEvent

  alias ClientsManager.Client.Client
  alias ClientsManager.Table
  alias ClientsManager.Messenger
  alias ClientsManager.Forwarder

  def handle_event(message, %{client_id: client_id,
                              redis_client: redis_client} = state) do
    case Table.find(:clients, client_id) do
      {:ok, {%{type: type, data: data} = client}} ->
        {msg, new_data} = Client.which_module(type, Handler)
                                .handle(message, data)
        Table.update(:clients, client_id, {Map.put(client, :data, new_data)})
        handle(msg, client_id, redis_client)
        {:ok, state}
      _ ->
        nil
    end
  end

  # client connected
  defp handle({:connected}, client_id, redis_client) do
    IO.puts("CONNECTED #{client_id}")
    Messenger.connected(redis_client, client_id)
  end

  # client found
  defp handle({:found}, client_id, redis_client) do
    IO.puts("FOUND #{client_id}")
    Messenger.found(redis_client, client_id)
  end

  # client sent message
  defp handle({:message, message}, client_id, redis_client) do
    IO.puts("MESSAGE #{client_id} #{message}")
    Forwarder.forward_from(client_id, message)
    Messenger.message(redis_client, client_id, message)
  end

  # client leaved dialog
  defp handle({:leaved}, client_id, redis_client) do
    IO.puts("LEAVED #{client_id}")
    Messenger.leaved(redis_client, client_id)
    handle({:closed}, client_id, redis_client)
  end

  # dialog closed
  defp handle({:closed}, client_id, redis_client) do
    IO.puts("CLOSED #{client_id}")
    Messenger.closed(redis_client, client_id)
  end

  # unknown message
  defp handle({:unknown}, _client_id, _redis_client) do
  end
end
