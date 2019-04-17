defmodule GVLWeb.LiveViewSocket do
  @moduledoc """
  The LiveView socket for Phoenix Endpoints.
  """
  use Phoenix.Socket

  defstruct id: nil,
            endpoint: nil,
            parent_pid: nil,
            assigns: %{},
            changed: %{},
            root_fingerprint: nil,
            private: %{},
            stopped: nil,
            connected?: false

  channel("lv:*", Phoenix.LiveView.Channel)

  @doc """
  Connects the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def connect(_params, %Phoenix.Socket{} = socket, _connect_info) do
    {:ok, socket}
  end

  @doc """
  Identifies the Phoenix.Socket for a LiveView client.
  """
  @impl Phoenix.Socket
  def id(_socket), do: nil
end
