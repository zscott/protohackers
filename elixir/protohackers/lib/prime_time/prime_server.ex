defmodule PrimeTime.PrimeServer do
  @moduledoc """
  A simple TCP echo server that responds to any message with the same message.
  """
  use GenServer

  require Logger

  @name "PrimeServer"
  @port 11001

  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  defstruct [:listen_socket]

  @impl true
  def init(:no_state) do
    Logger.info("Starting " <> @name)

    listen_options = [
      mode: :binary,
      active: false,
      reuseaddr: true,
      exit_on_close: false,
      packet: :line,
      buffer: 1024 * 100
    ]

    case :gen_tcp.listen(@port, listen_options) do
      {:ok, listen_socket} ->
        Logger.info(@name <> " listening on port " <> Integer.to_string(@port))
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
    Logger.info(@name <> " accepted connection")

    case recv_until_closed(socket) do
      :ok ->
        Logger.info(@name <> " closed connection")

      {:error, reason} ->
        Logger.error(@name <> " Failed to receive data: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  defp recv_until_closed(socket) do
    case :gen_tcp.recv(socket, 0, 5_000) do
      {:ok, line} ->
        Logger.info(@name <> " received data: #{inspect(line)}")
        :gen_tcp.send(socket, line)
        recv_until_closed(socket)

      {:error, :closed} ->
        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end
end
