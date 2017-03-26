defmodule ClientsManager.Client.Client do
  @moduledoc """
  Client model
  """

  alias ClientsManager.Nekto

  defstruct [:type, :data]

  @doc """
  Checks client on found
  """
  @spec found?(%ClientsManager.Client.Client{}) :: boolean
  def found?(%{type: type, data: data}) do
    which_module(type, Client).found?(data)
  end

  @doc """
  Returns module depends on type
  """
  @spec which_module(Atom.t) :: module
  def which_module(type) do
    case type do
      :nekto -> Nekto
    end
  end

  @doc """
  Concatenates module depends on type and passed module
  """
  @spec which_module(Atom.t, module) :: module
  def which_module(type, module) do
    type
    |> which_module()
    |> Module.concat(module)
  end
end
