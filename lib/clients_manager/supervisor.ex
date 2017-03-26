defmodule ClientsManager.Supervisor do
  @moduledoc """
  Clients manager supervisor
  """

  @type client_id :: Supervisor.child_id

  use Supervisor

  alias ClientsManager.Client
  alias ClientsManager.Table

  @doc """
  Starts supervisor
  """
  @spec start_link() :: {:ok, pid}
  def start_link do
    Table.create(:clients, [:public, :named_table])
    Supervisor.start_link(__MODULE__, [])
  end

  @doc """
  Stops supervisor
  """
  @spec stop(pid, reason :: term, timeout) :: :ok
  def stop(supervisor, reason \\ :normal, timeout \\ :infinity) do
    Table.destroy(:clients)
    Supervisor.stop(supervisor, reason, timeout)
  end

  @doc """
  Returns client's supervisor pid by client_id
  """
  @spec which_client(pid, client_id) :: pid
  def which_client(supervisor, client_id) do
    case which_child(supervisor, client_id) do
      {_, pid, _, _} -> {:ok, pid}
      _ -> :error
    end
  end

  @doc """
  Starts new client supervisor
  """
  @spec start_client(pid, client_id) :: Supervisor.on_start_child
  def start_client(supervisor, client_id) do
    {:ok, {client}} = Table.find(:clients, client_id)
    Supervisor.start_child(
      supervisor,
      supervisor(Client.Supervisor, [client_id, client], id: client_id)
    )
  end

  @doc """
  Stops client supervisor
  """
  @spec start_client(pid, client_id) :: :ok | {:error, error}
        when error: :not_found | :simple_one_for_one | :running | :restarting |
                    term
  def stop_client(supervisor, client_id) do
    Supervisor.terminate_child(supervisor, client_id)
    Supervisor.delete_child(supervisor, client_id)
  end

  @doc """
  Returns child by child_id
  """
  @spec which_child(pid, Supervisor.child_id) ::
        {Supervisor.Spec.child_id | :undefined,
          Supervisor.child | :restarting,
          Supervisor.Spec.worker,
          Supervisor.Spec.modules}
  def which_child(supervisor, child_id) do
    supervisor
    |> Supervisor.which_children
    |> List.keyfind(child_id, 0)
  end

  def init([]) do
    children = []
    supervise(children, strategy: :one_for_one)
  end
end
