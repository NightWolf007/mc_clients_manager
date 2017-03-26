defmodule ClientsManager.Nekto.Client do
  @moduledoc """
  Client model
  """

  defstruct [:socket, :token, :search_options,
             :user, :dialog, request_counter: 1]

  @doc """
  Returns request id

  ## Examples

      iex> client = %ClientsManager.Nekto.Client{user: %{id: 10},
      ...>                                       request_counter: 1}
      iex> ClientsManager.Nekto.Client.request_id(client)
      "10_1"
  """
  @spec request_id(%ClientsManager.Nekto.Client{}) :: String.t
  def request_id(%{user: %{id: user_id}, request_counter: request_counter}) do
    "#{user_id}_#{request_counter}"
  end

  @doc """
  Returns client with incremented request counter

  ## Examples

      iex> client = %ClientsManager.Nekto.Client{request_counter: 10}
      iex> ClientsManager.Nekto.Client.inc_request_counter(client)
      %ClientsManager.Nekto.Client{request_counter: 11}
  """
  @spec inc_request_counter(%ClientsManager.Nekto.Client{}) ::
          %ClientsManager.Nekto.Client{}
  def inc_request_counter(%{request_counter: request_counter} = client) do
    Map.put(client, :request_counter, request_counter + 1)
  end

  @doc """
  Returns client with reseted request counter

  ## Examples

      iex> client = %ClientsManager.Nekto.Client{request_counter: 10}
      iex> ClientsManager.Nekto.Client.reset_request_counter(client)
      %ClientsManager.Nekto.Client{request_counter: 1}
  """
  @spec reset_request_counter(%ClientsManager.Nekto.Client{}) ::
          %ClientsManager.Nekto.Client{}
  def reset_request_counter(client) do
    Map.put(client, :request_counter, 1)
  end

  @doc """
  Returns true if client found

  ## Examples

      iex> client = %ClientsManager.Nekto.Client{dialog: %{id: 123}}
      iex> ClientsManager.Nekto.Client.found?(client)
      true

      iex> client = %ClientsManager.Nekto.Client{dialog: nil}
      iex> ClientsManager.Nekto.Client.found?(client)
      false
  """
  @spec found?(%ClientsManager.Nekto.Client{}) :: boolean
  def found?(%{dialog: dialog}) do
    !is_nil(dialog)
  end
end
