defmodule SmokeTest.EchoServer do
  @moduledoc """
  A simple TCP echo server that responds to any message with the same message.
  """
  use GenServer

  require Logger

  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  defstruct [:listen_socket]

  @impl true
  def init(:no_state) do
    Logger.info("Starting echo server")

    listen_options = [
      mode: :binary,
      active: false,
      reuseaddr: true,
      exit_on_close: false
    ]

    case :gen_tcp.listen(5001, listen_options) do
      {:ok, listen_socket} ->
        Logger.info("Echo server listening on port 5001")
        state = %__MODULE__{listen_socket: listen_socket}
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, %__MODULE__{} = state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        handle_connection(socket)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  defp handle_connection(socket) do
    Logger.info("Echo server accepted connection")

    case recv_until_closed(socket, _buffer = "") do
      {:ok, data} ->
        Logger.info("Sending data: #{inspect(data)}")
        :gen_tcp.send(socket, data)
      {:error, reason} ->
        Logger.error("Failed to receive data: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  defp recv_until_closed(socket, buffer) do
    Logger.info("recv_until_closed(#{inspect(buffer)})")
    case :gen_tcp.recv(socket, 0, 5_000) do
      {:ok, data} ->
        recv_until_closed(socket, [buffer, data])

      {:error, :closed} ->
        {:ok, buffer}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
