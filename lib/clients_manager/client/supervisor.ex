defmodule ClientsManager.Client.Supervisor do
  @moduledoc """
  Client supervisor
  """

  use Supervisor

  alias ClientsManager.Client.Manager
  alias ClientsManager.Client.Handler
  alias ClientsManager.Table

  @doc """
  Starts supervisor
  """
  @spec start_link(integer) :: {:ok, pid}
  def start_link(client_id) do
    {:ok, {client}} = Table.find(:clients, client_id)
    {:ok, pid} = Supervisor.start_link(__MODULE__, {client_id, client})
    start_receiver(pid, client_id, client)
    {:ok, pid}
  end

  @doc """
  Returns receiver's pid
  """
  @spec receiver(pid) :: pid
  def receiver(supervisor) do
    supervisor
    |> which_child(:receiver)
    |> elem(1)
  end

  @doc """
  Returns gen_event's pid
  """
  @spec gen_event(pid) :: pid
  def gen_event(supervisor) do
    supervisor
    |> which_child(:gen_event)
    |> elem(1)
  end

  @doc """
  Returns redis_client's pid
  """
  @spec redis_client(pid) :: pid
  def redis_client(supervisor) do
    supervisor
    |> which_child(:redis_client)
    |> elem(1)
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

  def init({client_id, client}) do
    children = [
      worker(GenEvent, [], id: :gen_event),
      worker(Exredis, [], id: :redis_client)
    ]
    Table.update(:clients, client_id,
                 {client |> Manager.connect! |> Manager.prepare!})
    supervise(children, strategy: :one_for_all)
  end

  defp start_receiver(supervisor, client_id, client) do
    gen_event = gen_event(supervisor)
    GenEvent.add_handler(
      gen_event, Handler,
      %{client_id: client_id, redis_client: redis_client(supervisor)}
    )
    Supervisor.start_child(
      supervisor,
      worker(Task, [fn -> Manager.listen!(client, gen_event) end],
             id: :receiver)
    )
  end
end
