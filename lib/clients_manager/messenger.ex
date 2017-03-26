defmodule ClientsManager.Messenger do
  @moduledoc """
  Provides functions for sending commands
  """

  @doc """
  Writes connected message
  """
  @spec connected(pid, integer) :: integer
  def connected(redis_client, client_id) do
    write(redis_client, client_id, %{type: :connected})
  end

  @doc """
  Writes found message
  """
  @spec found(pid, integer) :: integer
  def found(redis_client, client_id) do
    write(redis_client, client_id, %{type: :found})
  end

  @doc """
  Writes text message
  """
  @spec message(pid, integer, String.t) :: integer
  def message(redis_client, client_id, text) do
    write(redis_client, client_id, %{type: :message, text: text})
  end

  @doc """
  Writes leaved message
  """
  @spec leaved(pid, integer) :: integer
  def leaved(redis_client, client_id) do
    write(redis_client, client_id, %{type: :leaved})
  end

  @doc """
  Writes closed message
  """
  @spec closed(pid, integer) :: integer
  def closed(redis_client, client_id) do
    write(redis_client, client_id, %{type: :closed})
  end

  defp write(redis_client, client_id, message) do
    Exredis.Api.publish(
      redis_client,
      "#{namespace()}:messages:#{client_id}",
      Poison.encode!(message)
    )
  end

  defp namespace do
    Application.get_env(:clients_manager, :namespace)
  end
end
