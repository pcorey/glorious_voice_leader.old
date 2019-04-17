defmodule TermSerializer do
  @moduledoc false
  @behaviour Phoenix.Transports.Serializer

  alias Phoenix.Socket.{Reply, Message, Broadcast}

  def fastlane!(%Broadcast{} = msg) do
    data =
      Phoenix.json_library().encode_to_iodata!([
        nil,
        nil,
        msg.topic,
        msg.event,
        msg.payload |> :erlang.term_to_binary() |> Base.encode64()
      ])

    {:socket_push, :text, data}
  end

  def encode!(%Reply{} = reply) do
    data = [
      reply.join_ref,
      reply.ref,
      reply.topic,
      "phx_reply",
      %{
        status: reply.status,
        response: reply.payload |> :erlang.term_to_binary() |> Base.encode64()
      }
    ]

    {:socket_push, :text, Phoenix.json_library().encode_to_iodata!(data)}
  end

  def encode!(%Message{} = msg) do
    data = [
      msg.join_ref,
      msg.ref,
      msg.topic,
      msg.event,
      msg.payload |> :erlang.term_to_binary() |> Base.encode64()
    ]

    {:socket_push, :text, Phoenix.json_library().encode_to_iodata!(data)}
  end

  def decode!(raw_message, _opts) do
    [join_ref, ref, topic, event, payload | _] = Phoenix.json_library().decode!(raw_message)

    %Phoenix.Socket.Message{
      topic: topic,
      event: event,
      payload: decode(payload),
      ref: ref,
      join_ref: join_ref
    }
  end

  defp decode(data) when is_binary(data) do
    data
    |> Base.decode64!()
    |> :erlang.binary_to_term(data)
  end

  defp decode(data) do
    data
  end
end
