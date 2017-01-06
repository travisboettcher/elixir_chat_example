defmodule Server do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def connect(server, sender, username) do
    GenServer.call(server, {sender, :connect, username})
  end

  def broadcast(server, sender, msg) do
    GenServer.cast(server, {sender, :broadcast, msg})
  end

  defp broadcast_msg(msg, clients) do
    Enum.each clients, fn {_, pid} -> Client.rec_msg(pid, msg) end
  end

  defp broadcast_info(info, clients) do
    Enum.each clients, fn {_, pid} -> Client.rec_info(pid, info) end
  end

  defp find(sender, [{u, p} | _]) when p == sender, do: u
  defp find(sender, [_ | t]), do: find(sender, t)

  ## GenServer callbacks
  
  def init(state) do
    Process.flag(:trap_exit, true)
    {:ok, state}
  end

  def handle_call({sender, :connect, username}, _from, clients) do
    Process.link(sender)
    broadcast_info(username <> " joined the chat", clients)
    {:reply, :connected, [{username, sender} | clients]}
  end

  def handle_cast({sender, :broadcast, msg}, clients) do
    broadcast_msg({find(sender, clients), msg}, clients)
    {:noreply, clients}
  end

  def handle_info({:EXIT, pid, _}, clients) do
    broadcast_info(find(pid, clients) <> " left the chat.", clients)
    {:noreply, clients |> Enum.filter(fn {_, rec} -> rec != pid end)}
  end
end
