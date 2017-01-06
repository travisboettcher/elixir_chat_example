defmodule Client do
  use GenServer

  def connect(username, server) do
    GenServer.start_link(__MODULE__, [username, server])
  end

  def send(client, msg) do
    GenServer.cast(client, {:send, msg})
  end

  def rec_info(client, info) do
    GenServer.cast(client, {:info, info})
  end

  def rec_msg(client, {username, msg}) do
    GenServer.cast(client, {:new_msg, username, msg})
  end

  def stop(client) do
    GenServer.stop(client)
  end

  ## GenServer callbacks

  def init([username, server] = state) do
    Server.connect(server, self(), username)
    {:ok, state}
  end

  def handle_cast({:send, msg}, [_, server] = state) do
    Server.broadcast(server, self(), msg)
    {:noreply, state}
  end

  def handle_cast({:info, msg}, [username, _] = state) do
    IO.puts(~s{[#{username}'s client] - #{msg}})
    {:noreply, state}
  end

  def handle_cast({:new_msg, from, msg}, [username, _] = state) do
    IO.puts(~s{[#{username}'s client] - #{from}: #{msg}})
    {:noreply, state}
  end

end
