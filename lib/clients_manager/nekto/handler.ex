defmodule ClientsManager.Nekto.Handler do
  @moduledoc """
  Provides functions for handling messages
  """

  @doc """
  Receives success_auth message and updates client
  """
  def handle({:success_auth, user}, client) do
    {{:connected}, Map.put(client, :user, user)}
  end

  @doc """
  Receives open_dialog message and updates client
  """
  def handle({:open_dialog, dialog}, client) do
    {{:found}, Map.put(client, :dialog, dialog)}
  end

  @doc """
  Receives chat_new_message message and forwards it
  """
  def handle({:chat_new_message, message}, client) do
    {{:message, message.text}, client}
  end

  @doc """
  Receives closed_dialog message and updates client
  """
  def handle({:close_dialog, _dialog}, client) do
    {{:leaved}, Map.put(client, :dialog, nil)}
  end

  @doc """
  Receives success_leave message and updates client
  """
  def handle({:success_leave, _dialog}, client) do
    {{:closed}, Map.put(client, :dialog, nil)}
  end

  def handle(_, client) do
    {{:unknown}, client}
  end
end
